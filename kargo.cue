@if(!NoKargo && !NoArgoRollouts && !NoArgoCD)
package holos

#Kargo: {
	Namespace: string
	Values: {...}
}

Kargo: #Kargo & {
	Namespace: "kargo"
}

// Register namespaces and components with the project.
Projects: {
	argocd: {
		namespaces: (Kargo.Namespace): _
		_components: {
			"kargo-secrets": _
			"kargo":         _
		}
	}
}
