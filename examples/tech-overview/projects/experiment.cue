package holos

// The development team registers a project name.
#Projects: experiment: {
	// The project owner must be named.
	Owner: Name: "dev-team"
	// The project exposes zero or more subdomains.  In this example
	// "podinfo.example.com" routes to the podinfo Service in the experiment
	// Namespace.
	Hostnames: podinfo: _
}
