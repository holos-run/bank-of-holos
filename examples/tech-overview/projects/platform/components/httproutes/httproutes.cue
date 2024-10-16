package holos

let Objects = {
	Name:      "httproutes"
	Resources: RESOURCES
}

// Produce a kubernetes objects build plan.
(#Kubernetes & Objects).BuildPlan

let RESOURCES = {
	for Project in #Projects {
		for Hostname in Project.Hostnames {
			HTTPRoute: "\(Project.Name)/\(Hostname.Name)": {
				metadata: name:      Hostname.Name + "." + #Organization.Domain
				metadata: namespace: IngressNamespace
				metadata: labels:    Project._CommonLabels
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

let IngressNamespace = "istio-ingress"
