package holos

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

_project: string @tag(project)
_cluster: string @tag(cluster)

Component: #Kubernetes & {
	Resources: {
		// The kargo.akuity.io/project label is the source of truth for what
		// Projects should be managed.
		for PROJECT in Projects[_project]._kargo_cluster_projects[_cluster] {
			Project: (PROJECT.metadata.name): _
		}
	}
}
