package holos

// Manage the component on every cluster in the platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):local-ca": {
			name:      "local-ca"
			component: "projects/platform/components/local-ca"
			cluster:   Cluster.name
		}
	}
}
