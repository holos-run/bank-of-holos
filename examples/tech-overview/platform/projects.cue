package holos

// Manage the component on every workload Cluster, but not management clusters.
for Cluster in _Fleets.workload.clusters {
	_Platform: Components: "\(Cluster.name):projects": {
		name:      "projects"
		component: "projects/platform/components/projects"
		cluster:   Cluster.name
	}
}
