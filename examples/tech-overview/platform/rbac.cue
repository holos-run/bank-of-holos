package holos

// Manage the component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name)/rbac": {
			path:    "projects/platform/components/rbac"
			cluster: Cluster.name
		}
	}
}
