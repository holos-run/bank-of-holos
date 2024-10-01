package holos

// The development team registers a project name.
#Projects: experiment: {
	// The project owner must be named.
	Owner: Name: "dev-team"
	// Expose Service podinfo at https://podinfo.example.com
	Hostnames: podinfo: Port: 9898
}
