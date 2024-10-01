package holos

import api "github.com/holos-run/holos/api/author/v1alpha3"

#Organization: api.#Organization & {
	Domain: "example.com"
}
#Platform: api.#Platform
#Fleets:   api.#StandardFleets

#ArgoConfig: api.#ArgoConfig & {
	ClusterName: _ClusterName
}

_ComponentConfig: {
	Resources:  #Resources
	ArgoConfig: #ArgoConfig
}

#Kubernetes: api.#Kubernetes & _ComponentConfig
