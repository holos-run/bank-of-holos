package holos

import core "github.com/holos-run/holos/api/core/v1alpha4"

// Output a Platform for holos to process
#Platform.Resource

// #Platform assembles a core Platform value in the Resource field to provide to
// the `holos` cli for processing.
#Platform: {
	Resource: core.#Platform & {
		metadata: name: "green-pinecone-mountain"
	}
}
