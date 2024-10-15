package holos

let Kustomization = {
	name: "argocd-crds"

	Kustomization: {
		resources: [
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(#ArgoCD.Version)/manifests/crds/application-crd.yaml",
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(#ArgoCD.Version)/manifests/crds/applicationset-crd.yaml",
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(#ArgoCD.Version)/manifests/crds/appproject-crd.yaml",
			// This method also works, but takes about 5 seconds longer each build.
			// "https://github.com/argoproj/argo-cd//manifests/crds/?ref=v\(#ArgoCD.Version)",
		]
	}
}

(#Kustomize & Kustomization).BuildPlan
