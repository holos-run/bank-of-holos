package holos

// Manage istio on workload clusters
for Cluster in _Fleets.workload.clusters {
	_Platform: Components: "\(Cluster.name):istio-gateway": {
		name:      "istio-gateway"
		component: "projects/platform/components/istio/gateway"
		cluster:   Cluster.name
	}
}
