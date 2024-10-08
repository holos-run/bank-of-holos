package holos

import core "github.com/holos-run/holos/api/core/v1alpha4"

// TODO: Lift this up into the Author API.
#BuildPlan: {
	Name:      string
	Resources: #Resources

	Resource: core.#BuildPlan & {
		metadata: name: Name
		spec: steps: [
			{
				generator: {
					apiObjectsEnabled: true
					apiObjects:        Resources
				}
				paths: component: _Tags.component
			},
		]
	}
}

// Constrain the output to the BuldPlan resource.
#BuildPlan.Resource
