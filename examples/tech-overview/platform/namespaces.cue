package holos

// Manage the component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):namespaces": {
			name:      "namespaces"
			component: "projects/platform/components/namespaces"
			cluster:   Cluster.name
		}
	}
}
