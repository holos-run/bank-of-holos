package holos

Projects: #Projects & {
	network: #ProjectBuilder & {
		_components: {
			"gateway-api": _
		}
	}

	argocd: #ProjectBuilder & {
		namespaces: argocd: _
		// Additional components to manage on every cluster.
		_components: {
			projects: name: "app-projects"
			crds:   _
			argocd: _
		}
	}

	addons: #ProjectBuilder & {
		namespaces: "external-secrets": _
		namespaces: "cert-manager":     _
	}

	jeff: #ProjectBuilder & {
		namespaces: jeff: _
	}
}

// Define at least the platform project.  Other components can register projects
// the same way from the root of the configuration.
AppProjects: #AppProjects

for PROJECT in Projects {
	AppProjects: (PROJECT.name): _
}
