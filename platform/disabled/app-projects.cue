package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):app-projects": {
			name:      "app-projects"
			component: "projects/platform/components/app-projects"
			cluster:   Cluster.name
		}
	}
}
