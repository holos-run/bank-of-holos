package holos

// Manage the component on every cluster in the platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):cert-manager": {
			name:      "cert-manager"
			component: "projects/platform/components/cert-manager"
			cluster:   Cluster.name
		}
	}
}
