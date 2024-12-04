package holos

import "github.com/holos-run/holos/api/core/v1alpha5:core"

#Components: [string]: core.#Component

// #Project represents a security boundary.
#Project: {
	name: string
	team: string
	// TODO: deprecate the singular environment, use environments instead.
	environment?: string
	stack?:       string
	environments: #Environments
	namespaces:   #Namespaces
	components:   #Components
	clusters:     #Clusters
}

#Projects: [NAME=string]: #Project & {name: NAME}

// Manage the base structure of the project on all clusters.
#ProjectBuilder: #Project & {
	name:         _
	namespaces:   _
	team:         string | *"platform"
	environment?: _
	stack?:       _
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
				if stack != _|_ {
					_stack: stack
				}
				if environment != _|_ {
					_environment: environment
				}
			}
			components: (NAMESPACE_COMPONENT.name): NAMESPACE_COMPONENT.component
		}

		// Mix in additional components
		for MIXIN_COMPONENT in _components {
			let COMPONENT = #ProjectClusterComponent & {
				_project:   NAME
				_cluster:   CLUSTER.name
				_component: MIXIN_COMPONENT.name
				_team:      team
				if stack != _|_ {
					_stack: stack
				}
				if environment != _|_ {
					_environment: environment
				}
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
	_project:      string
	_cluster:      string
	_component:    string
	_team:         string
	_environment?: string
	_stack?:       string

	name: "project:\(_project):cluster:\(_cluster):component:\(_component)"
	component: core.#Component & {
		name: _component
		path: string | *"projects/\(_project)/components/\(_component)"
		labels: {
			"app.holos.run/project.name":   _project
			"app.holos.run/cluster.name":   _cluster
			"app.holos.run/team.name":      _team
			"app.holos.run/component.name": _component
			if _environment != _|_ {
				"app.holos.run/environment.name": _environment
			}
			if _stack != _|_ {
				"app.holos.run/stack.name": _stack
			}
		}
		annotations: "app.holos.run/description": "\(name) for project \(_project) on cluster \(_cluster)"
		parameters: {
			project: _project
			cluster: _cluster
			if _environment != _|_ {
				EnvironmentName: _environment
			}
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
