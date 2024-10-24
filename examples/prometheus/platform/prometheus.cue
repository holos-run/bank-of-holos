package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):prometheus": {
			name:      "prometheus"
			component: "projects/platform/components/prometheus"
			cluster:   Cluster.name
		}
	}
}
