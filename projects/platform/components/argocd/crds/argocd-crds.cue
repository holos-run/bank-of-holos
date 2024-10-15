package holos

let Kustomization = {
	name: "argocd-crds"

	Kustomization: {
		resources: [
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(#ArgoCD.Version)/manifests/crds/application-crd.yaml",
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(#ArgoCD.Version)/manifests/crds/applicationset-crd.yaml",
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(#ArgoCD.Version)/manifests/crds/appproject-crd.yaml",
		]
	}
}

(#Kustomize & Kustomization).BuildPlan
