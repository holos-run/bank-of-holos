package holos

import ap "argoproj.io/appproject/v1alpha1"

// Registration point for AppProjects
#AppProjects: [Name=string]: ap.#AppProject & {
	metadata: name:      Name
	metadata: namespace: _ArgoCD.Namespace
	spec: description:   string | *"Holos managed AppProject for \(_Organization.DisplayName)"
	spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
	spec: destinations: [{namespace: "*", server: "*"}]
	spec: sourceRepos: ["*"]
}

// Define at least the platform project.  Other components can register projects
// the same way from the root of the configuration.
_AppProjects: #AppProjects & {platform: _}
