package holos

// _ArgoCD represents platform wide configuration
_ArgoCD: #ArgoCD & {
	Version:   "2.12.3"
	Namespace: "argocd"
}

#ArgoCD: {
	Version:   string
	Namespace: string
}

// Register namespaces
_Namespaces: (_ArgoCD.Namespace): _

// Register the HTTPRoute to the backend Service
_HTTPRoutes: argocd: _backendRefs: "argocd-server": namespace: _ArgoCD.Namespace
