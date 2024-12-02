package holos

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

_project: string @tag(project)
_cluster: string @tag(cluster)

Component: #Kubernetes & {
	Resources: Namespace: Projects[_project].namespaces
}
