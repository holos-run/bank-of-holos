package holos

_Kubernetes: #Kubernetes & {
	Name: "app-projects"
	Resources: AppProject: _AppProjects
}

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan
