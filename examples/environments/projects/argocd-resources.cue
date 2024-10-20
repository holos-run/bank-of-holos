package holos

// Register namespaces
_Namespaces: (_ArgoCD.Namespace): _

// Register the HTTPRoute to the backend Service
_HTTPRoutes: argocd: _backendRefs: "argocd-server": namespace: _ArgoCD.Namespace
