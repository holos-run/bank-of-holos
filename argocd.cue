@if(!NoArgoCD)
package holos

import ap "argoproj.io/appproject/v1alpha1"

// ArgoCD AppProject
#AppProject: ap.#AppProject & {
	metadata: name:      string
	metadata: namespace: string | *"argocd"
	spec: description:   string | *"Holos managed AppProject"
	spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
	spec: destinations: [{namespace: "*", server: "*"}]
	spec: sourceRepos: ["*"]
}

// Registration point for AppProjects
#AppProjects: [NAME=string]: #AppProject & {metadata: name: NAME}

// Register the ArgoCD Project namespaces and components
Projects: {
	argocd: #ProjectBuilder & {
		namespaces: argocd: _
		_components: {
			projects: name: "app-projects"
			crds: name:     "argocd-crds"
			crds: path:     "projects/argocd/components/crds"
			argocd: _
		}
	}
}

// Define at least the platform project.  Other components can register projects
// the same way from the root of the configuration.
AppProjects: #AppProjects

for PROJECT in Projects {
	AppProjects: (PROJECT.name): _
}

// _ArgoCD represents platform wide configuration
ArgoCD: #ArgoCD & {
	Version:   "2.12.3"
	Namespace: "argocd"
}

#ArgoCD: {
	Version:   string
	Namespace: string
}

// Register the HTTPRoute to the backend Service
HTTPRoutes: argocd: _backendRefs: "argocd-server": namespace: ArgoCD.Namespace
