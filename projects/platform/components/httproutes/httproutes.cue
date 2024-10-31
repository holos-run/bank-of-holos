package holos

_Kubernetes: #Kubernetes & {
	Name: "httproutes"
	Resources: HTTPRoute: _HTTPRoutes
}

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan
