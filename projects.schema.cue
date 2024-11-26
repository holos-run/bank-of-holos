package holos

import "github.com/holos-run/holos/api/core/v1alpha5:core"

#Components: [string]: core.#Component

#Project: {
	name:         string
	namespaces:   #Namespaces
	environments: #Environments
	clusters:     #Clusters
	components:   #Components
}

#Projects: [NAME=string]: #Project & {name: NAME}

// Manage the base structure of the project on all clusters.
#ProjectBuilder: #Project & {
	name: _
	let NAME = name

	clusters: _
	for ClusterSet in ClusterSets {
		for Cluster in ClusterSet.clusters {
			clusters: (Cluster.name): Cluster
		}
	}

	// TODO: Loop over environments too.
	for CLUSTER in clusters {
		components: {
			"project:\(NAME):cluster:\(CLUSTER.name):component:namespaces": {
				name: "namespaces"
				path: "teams/platform/components/namespaces"
				labels: {
					"app.holos.run/project.name":   NAME
					"app.holos.run/cluster.name":   CLUSTER.name
					"app.holos.run/component.name": name
				}
				annotations: "app.holos.run/description": "\(name) for project \(NAME) on cluster \(CLUSTER.name)"
				parameters: {
					project:       NAME
					cluster:       CLUSTER.name
					outputBaseDir: "projects/\(NAME)/clusters/\(CLUSTER.name)"
				}
			}
		}
	}
}
