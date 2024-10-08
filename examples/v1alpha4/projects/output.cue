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

	Application: app.#Application & {
		metadata: name:      ComponentName
		metadata: namespace: "argocd"
		spec: {
			destination: server: "https://kubernetes.default.svc"
			project: ArgoConfig.AppProject
			source: {
				path:           "\(ArgoConfig.DeployRoot)/deploy/clusters/\(ArgoConfig.ClusterName)/components/\(ComponentName)"
				repoURL:        ArgoConfig.RepoURL
				targetRevision: ArgoConfig.TargetRevision
			}
		}
	}

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
		spec: steps: [
			{
				manifest:  "clusters/\(_Tags.cluster)/components/\(metadata.name)/\(metadata.name).gen.yaml"
				generator: Generator
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
