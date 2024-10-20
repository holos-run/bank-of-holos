package holos

// #ArgoCD represents platform wide configuration
#ArgoCD: {
	AppVersion:   string
	ChartVersion: string
	Namespace:    string
}

_ArgoCD: #ArgoCD & {
	// helm search repo argocd to get current versions
	AppVersion:   "2.12.6"
	ChartVersion: "7.6.12"
	Namespace:    "argocd"
}

// Register namespaces
_Namespaces: (_ArgoCD.Namespace): _

// Register the HTTPRoute to the backend Service
_HTTPRoutes: argocd: _backendRefs: "argocd-server": namespace: _ArgoCD.Namespace
