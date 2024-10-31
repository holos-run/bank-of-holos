package holos

import ap "argoproj.io/appproject/v1alpha1"

#AppProject: ap.#AppProject & {
	metadata: name:      string
	metadata: namespace: _ArgoCD.Namespace
	spec: description:   string | *"Holos managed AppProject for \(_Organization.DisplayName)"
	spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
	spec: destinations: [{namespace: "*", server: "*"}]
	spec: sourceRepos: ["*"]
}

// Registration point for AppProjects
#AppProjects: [Name=string]: #AppProject & {
	metadata: name: Name
}

// Define at least the platform project.  Other components can register projects
// the same way from the root of the configuration.
_AppProjects: #AppProjects & {
	platform: _
}
