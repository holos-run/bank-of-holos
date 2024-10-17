package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

// This component is manages standard resources for each project.  The platform
// team manages this component.  Standardized project resources are derived from
// data provided by development teams when the register their project with the
// #Projects struct.
_Kubernetes: #Kubernetes & {
	Name: "projects"
	Resources: {
		for Project in #Projects {
			// Manage standard resources in each project namespace.
			for Namespace in Project.Namespaces {
				// Grant the project team admin access to their namespace.
				RoleBinding: "\(Namespace.Name)/admin": {
					metadata: name:      "admin"
					metadata: namespace: Namespace.Name
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
					spec: provider: {
						kubernetes: {
							remoteNamespace: metadata.namespace
							auth: token: bearerToken: key:  "token"
							auth: token: bearerToken: name: "eso-reader"
							server: ManagementCluster
						}
					}
				}

				// Allow HTTPRoutes in the ingress gateway namespace to reference Services
				// in the project namespace.
				ReferenceGrant: "\(Namespace.Name)/istio-ingress": {
					metadata: name:      IngressNamespace
					metadata: namespace: Namespace.Name
					spec: from: [{
						group:     "gateway.networking.k8s.io"
						kind:      "HTTPRoute"
						namespace: IngressNamespace
					}]
					spec: to: [{
						group: ""
						kind:  "Service"
					}]
				}
			}
		}
	}
}

let IngressNamespace = "istio-ingress"

let ManagementCluster = {
	url:      "https://management.example.com:6443"
	caBundle: "LS0tLS1CRUd...QVRFLS0tLS0K"
}
