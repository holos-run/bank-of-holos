package holos

// Manage the Component on every Cluster in the Platform
for ClusterSet in ClusterSets {
	for Cluster in ClusterSet.clusters {
		Platform: Components: "\(Cluster.name):namespaces": {
			name: "namespaces"
			path: "projects/platform/components/namespaces"
			annotations: "app.holos.run/description": "\(name) for cluster \(Cluster.name)"
			parameters: {
				outputBaseDir: "clusters/\(Cluster.name)"
			}
		}
	}
}
