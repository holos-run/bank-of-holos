package holos

import api "github.com/holos-run/holos/api/author/v1alpha4"

#Organization: api.#Organization & {
	Domain: "example.com"
}

#ArgoConfig: api.#ArgoConfig & {
	Root: "./examples/tech-overview/deploy"
}
