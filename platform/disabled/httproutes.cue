package holos

// Manage on workload clusters
for Cluster in _Fleets.workload.clusters {
	_Platform: Components: "\(Cluster.name):httproutes": {
		name:      "httproutes"
		component: "projects/platform/components/httproutes"
		cluster:   Cluster.name
	}
}
