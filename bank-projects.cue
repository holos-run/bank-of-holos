@if(!NoBank)
package holos

// Platform wide configuration.
BankOfHolos: #BankOfHolos & {
	Name: string | *"bank-of-holos"

	Frontend: Namespace: "bank-frontend"
	Backend: Namespace:  "bank-backend"
	Security: Namespace: "bank-security"
}

// Bank secrets are managed as part of the security project.
Projects: security: {
	namespaces: (BankOfHolos.Security.Namespace): _
	_components: {
		"bank-secrets": _
	}
}

// Register the HTTPRoute to the backend Service
HTTPRoutes: bank: _backendRefs: frontend: namespace: BankOfHolos.Frontend.Namespace

// Platform wide schema definition.
#BankOfHolos: {
	Name: string
	Frontend: Namespace: string
	Backend: Namespace:  string
	Security: Namespace: string

	// Resources to manage in each of the namespaces.
	Resources: #Resources
}
