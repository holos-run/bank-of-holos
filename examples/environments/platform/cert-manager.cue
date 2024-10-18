package holos

// Manage the component on every cluster in the platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name):cert-manager": {
			name:      "cert-manager"
			component: "projects/platform/components/cert-manager"
			cluster:   Cluster.name
		}
	}
}
