package holos

// #ArgoCD defines the schema of the platform wide configuration.
#ArgoCD: {
	AppVersion:   string
	ChartVersion: string
	Namespace:    string | *"argocd"
}

// helm search repo argocd to get current versions
_ArgoCD: #ArgoCD & {
	AppVersion:   "2.12.3"
	ChartVersion: "7.5.2"
}
