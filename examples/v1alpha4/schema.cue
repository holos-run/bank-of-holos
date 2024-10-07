package holos

import (
	api "github.com/holos-run/holos/api/author/v1alpha3"
	core "github.com/holos-run/holos/api/core/v1alpha4"
)

// TODO: Define Platform in the author api once the core API is good to go.
#Platform: {
	Resource: core.#Platform
}

#Organization: api.#Organization & {
	Domain: "example.com"
}

#Fleets: api.#StandardFleets

// BEGIN Refactor to output #Component.BuildPlan
// if the render component tag is set.

#ArgoConfig: api.#ArgoConfig & {
	ClusterName: _ClusterName
	DeployRoot:  "./examples/tech-overview"
}

_ComponentConfig: {
	Resources:  #Resources
	ArgoConfig: #ArgoConfig
}

#Helm:      api.#Helm & _ComponentConfig
#Kustomize: api.#Kustomize & _ComponentConfig

#Kubernetes: api.#Kubernetes & _ComponentConfig

// END Refactor to output #Component.BuildPlan
