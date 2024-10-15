package holos

// Manage istio on workload clusters
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: "\(Cluster.name):istio-gateway": {
		name:      "istio-gateway"
		component: "projects/platform/components/istio/gateway"
		cluster:   Cluster.name
	}
}
