package holos

let Objects = {
	Name:      "httproutes"
	Resources: RESOURCES
}

// Produce a kubernetes objects build plan.
(#Kubernetes & Objects).BuildPlan

let RESOURCES = {
	for Project in #Projects {
		let CommonLabels = {
			"\(#Organization.Domain)/project.name": Project.Name
			"\(#Organization.Domain)/owner.name":   Project.Owner.Name
			"\(#Organization.Domain)/owner.email":  Project.Owner.Email
		}

		// Add common labels to all of the standard resources.
		[_]: [_]: metadata: labels: CommonLabels

		for Hostname in Project.Hostnames {
			HTTPRoute: "\(Project.Name)/\(Hostname.Name)": {
				metadata: name:      Hostname.Name + "." + #Platform.Domain
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

let IngressNamespace = "istio-ingress"
