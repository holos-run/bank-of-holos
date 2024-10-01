package holos

import api "github.com/holos-run/holos/api/author/v1alpha3"

#Organization: api.#Organization & {
	Domain: "example.com"
}
#Platform: api.#Platform
#Fleets:   api.#StandardFleets

#ArgoConfig: api.#ArgoConfig & {
	ClusterName: _ClusterName
	DeployRoot:  "./examples/tech-overview"
}

_ComponentConfig: {
	Resources:  #Resources
	ArgoConfig: #ArgoConfig
}

#Helm:       api.#Helm & _ComponentConfig
#Kustomize:  api.#Kustomize & _ComponentConfig
#Kubernetes: api.#Kubernetes & _ComponentConfig
