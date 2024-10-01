package holos

// Manage the component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name)/projects": {
			path:    "projects/platform/components/projects"
			cluster: Cluster.name
		}
	}
}
