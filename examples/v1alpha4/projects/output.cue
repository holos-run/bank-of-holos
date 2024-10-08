package holos

import (
	core "github.com/holos-run/holos/api/core/v1alpha4"
	ks "sigs.k8s.io/kustomize/api/types"
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
		}

		kustomize?: core.#Kustomize
		if kustomize != _|_ {
			kustomizeEnabled: true
		}

		apiObjects?: core.#APIObjects
		for k, v in Resources {
			apiObjects: (k): v
		}
		if apiObjects != _|_ {
			apiObjectsEnabled: true
		}
	}

	Transformer?: {
		kustomize: kustomization: ks.#Kustomization
	}

	Resource: core.#BuildPlan & {
		metadata: name:  Name
		spec: component: _Tags.component
		spec: steps: [{
			name:      metadata.name
			generator: Generator
			if Transformer != _|_ {
				transformers: [Transformer]
			}
			manifest: "clusters/\(_Tags.cluster)/components/\(name)/\(name).gen.yaml"
		}]
	}
}

_BuildPlan: #BuildPlan

// Constrain the output to the BuldPlan resource.
_BuildPlan.Resource
