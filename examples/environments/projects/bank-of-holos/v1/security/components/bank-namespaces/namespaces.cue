package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

_Kubernetes: #Kubernetes & {
	Resources: Namespace: _Stack.Namespaces
}
