package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

_Kubernetes: #Kubernetes & {
	Name: "app-projects"
	Resources: {
		for Project in _Projects {
			// Manage an AppProject for the project.
			AppProject: (Project.Name): {
				metadata: name:      Project.Name
				metadata: namespace: "argocd"
				metadata: labels:    Project.CommonLabels
				spec: description:   string | *"Managed AppProject for \(_Organization.DisplayName)"
				spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
				spec: destinations: [{namespace: "*", server: "*"}]
				spec: sourceRepos: ["*"]
			}
		}
	}
}
