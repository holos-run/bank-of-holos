package holos

// Manage the component on every workload Cluster, but not management clusters.
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: "\(Cluster.name)/app-projects": {
		path:    "projects/platform/components/app-projects"
		cluster: Cluster.name
	}
}
