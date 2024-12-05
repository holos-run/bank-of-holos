@if(!NoKargo && !NoArgoRollouts && !NoArgoCD)
package holos

let IMAGE = "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/frontend"

holos: Component.BuildPlan

Component: #Kubernetes & {
	Name:          _
	OutputBaseDir: _
	_OutPath:      "\(OutputBaseDir)/components/\(Name)"

	Resources: {
		[_]: [_]: metadata: namespace: ProjectName

		Warehouse: frontend: {
			spec: {
				subscriptions: [{
					image: {
						repoURL:          IMAGE
						semverConstraint: "^v0.6.5"
						discoveryLimit:   5
					}
				}]
			}
		}

		for ENV in BankOfHolos.Tiers[TierName].environments {
			// TODO: Unify with the bank-frontend component somehow.
			let FrontendName = "\(ENV.name)-frontend"
			let OutPath = "deploy/clusters/\(ClusterName)/projects/bank-web/components/\(FrontendName)"

			Stage: (FrontendName): {
				spec: {
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
											branch: "stage/\(ENV.name)"
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
									// TODO: Pick up replacing component name in the path with the
									// path to the frontend artifact.
									path: "\(SRC)/\(OutPath)"
									images: [{image: IMAGE}]
								}
							},
							{
								uses: "kustomize-build"
								config: {
									path:    "\(SRC)/\(OutPath)"
									outPath: "\(OUT)/\(OutPath)/\(FrontendName).gen.yaml"
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
									targetBranch: "stage/\(ENV.name)"
								}
							},
							{
								uses: "argocd-update"
								config: {
									apps: [{
										name: "bank-web-\(FrontendName)"
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
		}
	}
}
