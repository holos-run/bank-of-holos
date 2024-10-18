package holos

// Manage the component on every cluster in the platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name):external-secrets-crds": {
			name:      "external-secrets-crds"
			component: "projects/platform/components/external-secrets-crds"
			cluster:   Cluster.name
		}
		#Platform: Components: "\(Cluster.name):external-secrets": {
			name:      "external-secrets"
			component: "projects/platform/components/external-secrets"
			cluster:   Cluster.name
		}
	}
}
