package holos

// Manage the component on every workload Cluster, but not management clusters.
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: "\(Cluster.name):app-projects": {
		name:      "app-projects"
		component: "projects/platform/components/app-projects"
		cluster:   Cluster.name
	}
}
