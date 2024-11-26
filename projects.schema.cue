package holos

import (
	"github.com/holos-run/holos/api/core/v1alpha5:core"
	ap "argoproj.io/appproject/v1alpha1"
)

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
	_components: #Components

	clusters: _
	for ClusterSet in ClusterSets {
		for Cluster in ClusterSet.clusters {
			clusters: (Cluster.name): Cluster
		}
	}

	// TODO: Loop over environments too.
	for CLUSTER in clusters {
		// Manage namespaces associated with the project.
		let NAMESPACE_COMPONENT = #ProjectClusterComponent & {
			_project:   NAME
			_cluster:   CLUSTER.name
			_component: "namespaces"
			_team:      "platform"
		}
		components: (NAMESPACE_COMPONENT.name): NAMESPACE_COMPONENT.component

		// Mix in additional components
		for MIXIN_COMPONENT in _components {
			let COMPONENT = #ProjectClusterComponent & {
				_project:   NAME
				_cluster:   CLUSTER.name
				_component: MIXIN_COMPONENT.name
				_team:      "platform"
			}
			components: (COMPONENT.name): COMPONENT.component
		}
	}
}

// #ProjectClusterComponent represents the conventional way to register a
// component with the platform.  The component is part of a project, managed on
// a specific cluster, and owned by a named team.
//
// The component definition is located in a team specific path for OWNERS
// support.
#ProjectClusterComponent: {
	_project:   string
	_cluster:   string
	_component: string
	_team:      string

	name: "project:\(_project):cluster:\(_cluster):component:\(_component)"
	component: core.#Component & {
		name: _component
		path: "teams/\(_team)/components/\(_component)"
		labels: {
			"app.holos.run/project.name":   _project
			"app.holos.run/cluster.name":   _cluster
			"app.holos.run/team.name":      _team
			"app.holos.run/component.name": _component
		}
		annotations: "app.holos.run/description": "\(name) for project \(_project) on cluster \(_cluster)"
		parameters: {
			project:       _project
			cluster:       _cluster
			outputBaseDir: "clusters/\(_cluster)/projects/\(_project)"
		}
	}
}

// ArgoCD AppProject
#AppProject: ap.#AppProject & {
	metadata: name:      string
	metadata: namespace: string | *"argocd"
	spec: description:   string | *"Holos managed AppProject"
	spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
	spec: destinations: [{namespace: "*", server: "*"}]
	spec: sourceRepos: ["*"]
}

#ClusterComponent: {
	_cluster:   string
	_component: string
	_team:      string

	name: "cluster:\(_cluster):component:\(_component)"
	component: core.#Component & {
		name: _component
		path: "teams/\(_team)/components/\(_component)"
		labels: {
			"app.holos.run/cluster.name":   _cluster
			"app.holos.run/team.name":      _team
			"app.holos.run/component.name": _component
		}
		annotations: "app.holos.run/description": "\(name) for on cluster \(_cluster)"
		parameters: {
			cluster:       _cluster
			outputBaseDir: "clusters/\(_cluster)"
		}
	}
}

// Registration point for AppProjects
#AppProjects: [NAME=string]: #AppProject & {metadata: name: NAME}
