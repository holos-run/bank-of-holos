package holos

// Manage the component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name)/namespaces": {
			path:    "projects/platform/components/namespaces"
			cluster: Cluster.name
		}
	}
}
