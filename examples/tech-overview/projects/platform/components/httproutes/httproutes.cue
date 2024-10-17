package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

_Kubernetes: #Kubernetes & {
	Name: "httproutes"
	Resources: {
		for Project in #Projects {
			for Hostname in Project.Hostnames {
				HTTPRoute: "\(Project.Name)/\(Hostname.Name)": {
					metadata: name:      Hostname.Name + "." + #Organization.Domain
					metadata: namespace: IngressNamespace
					spec: hostnames: [metadata.name]
					spec: parentRefs: [{
						name:      "default"
						namespace: metadata.namespace
					}]
					spec: rules: [
						{
							matches: [{
								path: type:  "PathPrefix"
								path: value: "/"
							}]
							backendRefs: [{
								name:      Hostname.Service
								namespace: Hostname.Namespace
								port:      Hostname.Port
							}]
						},
					]
				}
			}
		}
	}
}

let IngressNamespace = "istio-ingress"
