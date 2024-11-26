package holos

Clusters: #Clusters & {
	// Management Cluster
	management: region: "local"
	management: set:    "management"
	// Local Clusters
	local: region: "local"
}

// ClusterSets is dynamically built from the Clusters structure.
ClusterSets: #ClusterSets & {
	// Map every cluster into the correct set.
	for CLUSTER in Clusters {
		(CLUSTER.set): clusters: (CLUSTER.name): CLUSTER
	}
}
