package holos

// Manage on workload clusters only
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: "\(Cluster.name)/bank-secrets": {
		path:    "projects/bank-of-holos/security/components/bank-secrets"
		cluster: Cluster.name
	}
	#Platform: Components: "\(Cluster.name)/bank-frontend": {
		path:    "projects/bank-of-holos/frontend/components/bank-frontend"
		cluster: Cluster.name
	}
}