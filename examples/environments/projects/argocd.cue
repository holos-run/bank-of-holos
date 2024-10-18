package holos

// #ArgoCD represents platform wide configuration
#ArgoCD: {
	Version:   string
	Namespace: string
}
_ArgoCD: #ArgoCD & {
	Version:   "2.12.3"
	Namespace: "argocd"
}

// Register namespaces
_Namespaces: (_ArgoCD.Namespace): _

// Register the HTTPRoute to the backend Service
_HTTPRoutes: argocd: _backendRefs: "argocd-server": namespace: _ArgoCD.Namespace
