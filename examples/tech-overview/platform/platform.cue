package holos

import api "github.com/holos-run/holos/api/author/v1alpha4"

#Platform: api.#Platform & {
	Name: "technical-overview"
}

// Render a Platform resource for holos to process
#Platform.Resource
