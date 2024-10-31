package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):argocd-crds": {
			name:      "argocd-crds"
			component: "projects/platform/components/argocd/crds"
			cluster:   Cluster.name
		}
		_Platform: Components: "\(Cluster.name):argocd": {
			name:      "argocd"
			component: "projects/platform/components/argocd/argocd"
			cluster:   Cluster.name
		}
	}
}
