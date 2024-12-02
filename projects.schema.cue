package holos

import "github.com/holos-run/holos/api/core/v1alpha5:core"

#Components: [string]: core.#Component

#Project: {
	name:         string
	team:         string
	namespaces:   #Namespaces
	environments: #Environments
	clusters:     #Clusters
	components:   #Components
}

#Projects: [NAME=string]: #Project & {name: NAME}

// Manage the base structure of the project on all clusters.
#ProjectBuilder: #Project & {
	name:       _
	namespaces: _
	team:       string | *"platform"
	let NAME = name
	_components: #Components & {
		[NAME=string]: core.#Component & {
			name: string | *NAME
		}
	}

	clusters: _
	for ClusterSet in ClusterSets {
		for Cluster in ClusterSet.clusters {
			clusters: (Cluster.name): Cluster
		}
	}

	for CLUSTER in clusters {
		if len(namespaces) > 0 {
			// Manage namespaces associated with the project.  Note the namespaces
			// component itself is not associated with a project because it's a
			// foundational component used by all projects.
			let NAMESPACE_COMPONENT = #SharedComponent & {
				_project:   NAME
				_cluster:   CLUSTER.name
				_component: "namespaces"
				_team:      team
			}
			components: (NAMESPACE_COMPONENT.name): NAMESPACE_COMPONENT.component
		}

		// Mix in additional components
		for MIXIN_COMPONENT in _components {
			let COMPONENT = #ProjectClusterComponent & {
				_project:   NAME
				_cluster:   CLUSTER.name
				_component: MIXIN_COMPONENT.name
				_team:      "platform"
				component: path: MIXIN_COMPONENT.path
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
		path: string | *"projects/\(_project)/components/\(_component)"
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

// #SharedComponent represents a component shared across multiple projects.  For
// example, namespace management.
#SharedComponent: #ProjectClusterComponent & {
	_component: _
	component: path: "components/\(_component)"
}
