package holos

// Manage the component on every workload Cluster, but not management clusters.
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: "\(Cluster.name)/podinfo": {
		path:    "projects/experiment/components/podinfo"
		cluster: Cluster.name
	}
}
