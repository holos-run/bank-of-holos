package holos

#Organization: {
	DisplayName: string
	Domain:      string
	RepoURL:     string
}

// Override these values with cue build tags.  See organization-jeff.cue for an
// example.
Organization: #Organization & {
	DisplayName: string | *"Bank of Holos"
	Domain:      string | *"holos.localhost"
	RepoURL:     string | *"https://github.com/holos-run/bank-of-holos.git"
}
