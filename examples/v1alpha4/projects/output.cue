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

	Generator: {
		helm?: core.#Helm
		if helm != _|_ {
			helmEnabled: true
			helmFile:    "helm.gen.yaml"
		}
		helmFile?: _

		kustomize?: core.#Kustomize
		if kustomize != _|_ {
			kustomizeEnabled: true
			kustomizeFile:    "kustomize.gen.yaml"
		}
		kustomizeFile?: _

		apiObjects?: core.#APIObjects
		for k, v in Resources {
			apiObjects: (k): v
		}
		if apiObjects != _|_ {
			apiObjectsEnabled: true
			apiObjectsFile:    "api-objects.gen.yaml"
		}
		apiObjectsFile?: _
	}

	Transformer: {
		kustomize: kustomization: ks.#Kustomization & {
			commonLabels: "holos.run/component.name": Name
			_resources: {
				if Generator.helmFile != _|_ {
					helm: Generator.helmFile
				}
				if Generator.kustomizeFile != _|_ {
					kustomize: Generator.kustomizeFile
				}
				if Generator.apiObjectsFile != _|_ {
					kustomize: Generator.apiObjectsFile
				}
			}
			resources: [for x in _resources {x}]
		}
	}

	Resource: core.#BuildPlan & {
		metadata: name:  Name
		spec: component: _Tags.component
		spec: steps: [
			{
				manifest:  "clusters/\(_Tags.cluster)/components/\(metadata.name)/\(metadata.name).gen.yaml"
				generator: Generator
				if Transformer != _|_ {
					transformers: [Transformer]
				}
			},
			{
				manifest: "clusters/\(_Tags.cluster)/gitops/\(metadata.name).gen.yaml"
				generator: {
					apiObjectsEnabled: true
					apiObjects: Application: argocd: app.#Application & {
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
				}
				if Transformer != _|_ {
					transformers: [Transformer]
				}
			},
		]
	}
}

_BuildPlan: #BuildPlan

// Constrain the output to the BuldPlan resource.
_BuildPlan.Resource
