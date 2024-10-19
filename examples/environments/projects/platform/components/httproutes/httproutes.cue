package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

_Kubernetes: #Kubernetes & {
	Resources: HTTPRoute: _HTTPRoutes
}
