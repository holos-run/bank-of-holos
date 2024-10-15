package holos

// Manage the Component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name):app-projects": {
			name:      "app-projects"
			component: "projects/platform/components/app-projects"
			cluster:   Cluster.name
		}
	}
}
