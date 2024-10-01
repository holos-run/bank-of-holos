package holos

// This component is manages standard resources for each project.  The platform
// team manages this component.  Standardized project resources are derived from
// data provided by development teams when the register their project with the
// #Projects struct.
let Objects = {
	Name:      "projects"
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
			// Grant the project team admin access to their namespace.
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

			// Manage a SecretStore for the project team to sync secrets into their
			// namspace with ExternalSecret resources.  This is an example of pulling
			// secrets from a central management cluster.
			//
			// Note, this example is incomplete and for illustration only. In practice
			// an accompanying CronJob uses workload identity to periodically refresh
			// the bearer token Secret.
			SecretStore: "\(Namespace.Name)/default": {
				metadata: name:      "default"
				metadata: namespace: Namespace.Name
				metadata: labels:    CommonLabels
				spec: provider: {
					kubernetes: {
						remoteNamespace: metadata.namespace
						auth: token: bearerToken: key:  "token"
						auth: token: bearerToken: name: "eso-reader"
						server: ManagementCluster
					}
				}
			}
		}
	}
}

let ManagementCluster = {
	url:      "https://127.0.0.1"
	caBundle: "LS0tLS1CRUd...QVRFLS0tLS0K"
}
