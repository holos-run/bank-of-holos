package holos

_Kustomize: #Kustomize & {
	KustomizeConfig: {
		Resources: {
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(_ArgoCD.Version)/manifests/crds/application-crd.yaml":    _
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(_ArgoCD.Version)/manifests/crds/applicationset-crd.yaml": _
			"https://raw.githubusercontent.com/argoproj/argo-cd/v\(_ArgoCD.Version)/manifests/crds/appproject-crd.yaml":     _
		}
	}
}

_Kustomize.BuildPlan
