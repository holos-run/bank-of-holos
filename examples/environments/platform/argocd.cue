package holos

// Manage the Component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		#Platform: Components: "\(Cluster.name):argocd-crds": {
			name:      "argocd-crds"
			component: "projects/platform/components/argocd/crds"
			cluster:   Cluster.name
		}
		#Platform: Components: "\(Cluster.name):argocd": {
			name:      "argocd"
			component: "projects/platform/components/argocd/argocd"
			cluster:   Cluster.name
		}
	}
}
