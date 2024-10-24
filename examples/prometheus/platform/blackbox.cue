package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):blackbox": {
			name:      "blackbox"
			component: "projects/platform/components/blackbox"
			cluster:   Cluster.name
		}
	}
}
