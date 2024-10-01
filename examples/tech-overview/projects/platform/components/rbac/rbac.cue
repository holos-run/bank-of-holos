package holos

let Objects = {
	Name:      "rbac"
	Resources: _Resources
}

// Produce a kubernetes objects build plan.
(#Kubernetes & Objects).BuildPlan

_Resources: {
	for Project in #Projects {
		let CommonLabels = {
			"\(#Organization.Domain)/project.name": Project.Name
			"\(#Organization.Domain)/owner.name":   Project.Owner.Name
			"\(#Organization.Domain)/owner.email":  Project.Owner.Email
		}

		for Namespace in Project.Namespaces {
			RoleBinding: "\(Namespace.Name)/admin": {
				metadata: name:      "admin"
				metadata: namespace: Namespace.Name
				metadata: labels:    CommonLabels
				roleRef: {
					apiGroup: "rbac.authorization.k8s.io"
					kind:     "ClusterRole"
					name:     "admin"
				}
				subjects: [{
					apiGroup: "rbac.authorization.k8s.io"
					kind:     "Group"
					name:     "oidc:" + Project.Owner.Email
				}]
			}
		}
	}
}
