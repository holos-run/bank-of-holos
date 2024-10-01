package holos

// Manage the component on every workload Cluster, but not management clusters.
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: "\(Cluster.name)/httproutes": {
		path:    "projects/platform/components/httproutes"
		cluster: Cluster.name
	}
}
