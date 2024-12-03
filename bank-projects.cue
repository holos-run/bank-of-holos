@if(!NoBank)
package holos

// Platform wide configuration.
BankOfHolos: #BankOfHolos & {
	Name: string | *"bank-of-holos"

	Environments: {
		dev: tier:   "nonprod"
		test: tier:  "nonprod"
		stage: tier: "nonprod"
		prod: tier:  "prod"
	}

	EnvironmentNamespaces: {
		"bank-frontend": _
		"bank-backend":  _
		"bank-security": _
	}
}

// Projects are security boundaries, so manage one project for each environment
// and team combination.
for ENV in BankOfHolos.configuration.environments {
	Projects: "\(ENV.name)-bank-security": #ProjectBuilder & {
		team:        "security"
		stack:       BankOfHolos.Name
		environment: ENV.name
		// The security team manages namespaces for the whole stack.
		namespaces: BankOfHolos.configuration.environments[ENV.name].namespaces

		_components: {
			secrets: path: "projects/security/components/bank-secrets"
		}
	}

	Projects: "\(ENV.name)-bank-backend": #ProjectBuilder & {
		team:        "backend"
		stack:       BankOfHolos.Name
		environment: ENV.name

		_components: {
			// Configuration
			config: path: "projects/bank-backend/components/bank-backend-config"
			// Databases
			"accounts-db": path: "projects/bank-backend/components/bank-accounts-db"
			"ledger-db": path:   "projects/bank-backend/components/bank-ledger-db"
			// Services
			contacts: path: "projects/bank-backend/components/bank-contacts"
		}
	}

	Projects: "\(ENV.name)-bank-web": #ProjectBuilder & {
		team:        "frontend"
		stack:       BankOfHolos.Name
		environment: ENV.name

		_components: {
			frontend: path: "projects/bank-frontend/components/bank-frontend"
		}
	}

	// Register the HTTPRoute to the backend Service
	HTTPRoutes: "bank.\(ENV.name)": _backendRefs: frontend: namespace: ENV.frontend.namespace
}

// Platform wide schema definition.
#BankOfHolos: {
	Name: string

	// Environments to manage.
	Environments: #Environments
	// Namespaces to manage in each environment.
	EnvironmentNamespaces: #NamedObjects
	// Resources to manage in each of the namespaces.
	NamespaceResources: #Resources

	// Configuration constructed from the above fields.
	configuration: {
		environments: [NAME=string]: {
			name:       NAME
			namespaces: #Namespaces
			frontend: namespace: "\(NAME)-bank-frontend"
			backend: namespace:  "\(NAME)-bank-backend"
			security: namespace: "\(NAME)-bank-security"
		}

		for ENV in Environments {
			for NS in EnvironmentNamespaces {
				environments: (ENV.name): namespaces: "\(ENV.name)-\(NS.metadata.name)": _
			}
		}
	}
}
