@if(!NoKargo && !NoArgoRollouts && !NoArgoCD)
package holos

import ks "sigs.k8s.io/kustomize/api/types"

let IMAGE = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/frontend"

Component: {
	Name:          _
	OutputBaseDir: _
	_OutPath:      "\(OutputBaseDir)/components/\(Name)"

	// Write a kustomization.yaml to the deploy directory for Kargo to edit.
	Artifacts: kargoKustomization: {
		artifact: "\(_OutPath)/kustomization.yaml"
		generators: [{
			kind:   "Resources"
			output: artifact
			resources: Kustomization: kargo: ks.#Kustomization & {
				resources: ["\(Name).gen.yaml"]
			}
		}]
	}
}

Component: Resources: {
	Warehouse: frontend: spec: {
		subscriptions: [{
			image: {
				repoURL:          IMAGE
				semverConstraint: "^v0.6.5"
				discoveryLimit:   5
			}
		}]
	}
	Stage: (EnvironmentName): spec: {
		requestedFreight: [{
			origin: {
				kind: "Warehouse"
				name: Warehouse.frontend.metadata.name
			}
			sources: direct: true
		}]
		promotionTemplate: spec: {
			let SRC = "./src"
			let OUT = "./out"
			steps: [
				{
					uses: "git-clone"
					config: {
						repoURL: Organization.RepoURL
						checkout: [
							{
								branch: "main"
								path:   SRC
							},
							{
								branch: "stage/\(EnvironmentName)"
								path:   OUT
							},
						]
					}
				},
				{
					uses: "git-clear"
					config: path: OUT
				},
				{
					uses: "kustomize-set-image"
					as:   "update-image"
					config: {
						path: "\(SRC)/deploy/\(Component._OutPath)"
						images: [{image: IMAGE}]
					}
				},
				{
					uses: "kustomize-build"
					config: {
						path:    "\(SRC)/deploy/\(Component._OutPath)"
						outPath: "\(OUT)/deploy/\(Component._OutPath)/\(Component.Name).gen.yaml"
					}
				},
				{
					uses: "git-commit"
					as:   "commit"
					config: {
						path: OUT
						messageFromSteps: ["update-image"]
					}
				},
				{
					uses: "git-push"
					config: {
						path:         OUT
						targetBranch: "stage/\(EnvironmentName)"
					}
				},
				{
					uses: "argocd-update"
					config: {
						apps: [{
							name: Component._ArgoAppName
							sources: [{
								repoURL:               Organization.RepoURL
								desiredCommitFromStep: "commit"
							}]
						}]
					}
				},
			]
		}
	}
}
