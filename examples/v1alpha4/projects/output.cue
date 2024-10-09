package holos

import (
	core "github.com/holos-run/holos/api/core/v1alpha4"
	ks "sigs.k8s.io/kustomize/api/types"
	app "argoproj.io/application/v1alpha1"
)

// TODO: Lift this up into the Author API.
#BuildPlan: {
	Name: string

	// Mix-ins are the most common case, so name it simply "Resources"
	Resources: #Resources

	// Kustomize all generators of all build steps to add common labels.
	Transformer: {
		kustomize: kustomization: ks.#Kustomization & {
			commonLabels: "holos.run/component.name": Name
			_resources: {
				for artifact in Resource.spec.artifacts {
					for generator in artifact.generators {
						(generator.manifest): generator.manifest
					}
				}
			}
			resources: [for x in _resources {x}]
		}
	}

	Resource: core.#BuildPlan & {
		metadata: name:  Name
		spec: component: _Tags.component
		// We use to build steps for two distinct build artifacts.
		spec: artifacts: [
			{
				artifact: "clusters/\(_Tags.cluster)/components/\(Name)/\(Name).gen.yaml"
				generators: [{
					kind:      "Resources"
					manifest:  "resources.gen.yaml"
					resources: Resources
				}]
				transformers: [Transformer]
			},
			{
				artifact: "clusters/\(_Tags.cluster)/gitops/\(Name).gen.yaml"
				generators: [{
					kind:     "Resources"
					manifest: "application.gen.yaml"
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
				transformers: [Transformer]
			},
		]
	}
}

_BuildPlan: #BuildPlan

// Constrain the output to the BuldPlan resource.
_BuildPlan.Resource
