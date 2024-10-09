package holos

import core "github.com/holos-run/holos/api/core/v1alpha4"

// Output a Platform for holos to process
#Platform.Resource

// #Platform assembles a core Platform value in the Resource field to provide to
// the `holos` cli for processing.
#Platform: {
	Components: [_]: core.#Component

	// Resource represents the output Platform resource for holos to process.
	Resource: core.#Platform & {
		metadata: name: "green-pinecone-mountain"
		spec: components: [for x in Components {x}]
	}
}
