package holos

import (
	core "github.com/holos-run/holos/api/core/v1alpha4"
	ks "sigs.k8s.io/kustomize/api/types"
	app "argoproj.io/application/v1alpha1"
)

// TODO: Lift this up into the Author API.
#BuildPlan: {
	// Name is injected from the render platform command.
	Name: _Tags.name

	// Mix-ins are the most common case, so name it simply "Resources"
	Resources: #Resources

	// Kustomize all generators of all build steps to add common labels.
	Transformer: {
		kind: "Kustomize"
		kustomize: kustomization: ks.#Kustomization & {
			commonLabels: "holos.run/component.name": Name
		}
	}

	Resource: core.#BuildPlan & {
		metadata: name:  Name
		spec: component: _Tags.component
		// We use to build steps for two distinct build artifacts.
		spec: artifacts: [
			{
				artifact: "clusters/\(_Tags.cluster)/components/\(Name)/\(Name).gen.yaml"
				generators: [
					{
						kind:   "Resources"
						output: "1.yaml"
						resources: Namespace: jeff: #Namespaces["\(_Tags.environment)-jeff"]
					},
					{
						kind:   "Resources"
						output: "2.yaml"
						resources: Namespace: gary: #Namespaces["\(_Tags.environment)-gary"]
					},
					{
						kind:   "Resources"
						output: "3.yaml"
						resources: Namespace: nate: #Namespaces["\(_Tags.environment)-nate"]
					},
				]
				transformers: [{
					kind: "Join"
					inputs: [for x in generators {x.output}]
					output: artifact
				}]
			},
			{
				artifact: "clusters/\(_Tags.cluster)/gitops/\(Name).gen.yaml"
				let Output = "application.gen.yaml"
				generators: [{
					kind:   "Resources"
					output: Output
					resources: Application: argocd: app.#Application & {
						metadata: name:      Name
						metadata: namespace: "argocd"
						spec: {
							destination: server: "https://kubernetes.default.svc"
							project: "default"
							source: {
								path:           "examples/v1alpha4/deploy/clusters/\(_Tags.cluster)/components/\(metadata.name)"
								repoURL:        "https://github.com/holos-run/bank-of-holos"
								targetRevision: "main"
							}
						}
					}
				}]
				transformers: [Transformer & {
					inputs: [Output]
					output: artifact
					kustomize: kustomization: resources: inputs
				}]
			},
		]
	}
}

_BuildPlan: #BuildPlan

// Constrain the output to the BuldPlan resource.
_BuildPlan.Resource
