package holos

// #Istio represents platform wide configuration
// Manage istio on workload clusters
for Cluster in #Fleets.workload.clusters {
	#Platform: Components: {
		"\(Cluster.name):istio-base": {
			name:      "istio-base"
			component: "projects/platform/components/istio/base"
			cluster:   Cluster.name
		}
		"\(Cluster.name):istiod": {
			name:      "istiod"
			component: "projects/platform/components/istio/istiod"
			cluster:   Cluster.name
		}
		"\(Cluster.name):istio-cni": {
			name:      "istio-cni"
			component: "projects/platform/components/istio/cni"
			cluster:   Cluster.name
		}
		"\(Cluster.name):istio-ztunnel": {
			name:      "istio-ztunnel"
			component: "projects/platform/components/istio/ztunnel"
			cluster:   Cluster.name
		}
	}
}
