package holos

// Manage an ArgoCD AppProject resource for each project.
let Objects = {
	Name:      "app-projects"
	Resources: _Resources
}

// Produce a kubernetes objects build plan.
(#Kubernetes & Objects).BuildPlan

_Resources: {
	for Project in #Projects {
		// Manage an AppProject for the project.
		AppProject: (Project.Name): {
			metadata: name:      Project.Name
			metadata: namespace: "argocd"
			metadata: labels:    Project._CommonLabels
			spec: description:   string | *"Managed AppProject for \(#Organization.DisplayName)"
			spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
			spec: destinations: [{namespace: "*", server: "*"}]
			spec: sourceRepos: ["*"]
		}
	}
}
