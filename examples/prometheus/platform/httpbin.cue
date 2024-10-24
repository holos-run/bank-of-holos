package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):httpbin": {
			name:      "httpbin"
			component: "projects/platform/components/httpbin"
			cluster:   Cluster.name
		}
	}
}
