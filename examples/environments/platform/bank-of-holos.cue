package holos

// DEMO:ENVS ⓘ Shared environments defined here.
_SharedEnvironments: #Environment & {
	prod: _
	dev:  _
}

// Sandbox environments for individual contributors.
// DEMO:ENVS ☞ Add a new contributor here.
// DEMO:SECRETS ☞ Bump the stack version.
_SandboxEnvironments: #Sandbox & {
	jeff: Version: "v1"
}

// Stacks represents the collection of stacks across all environments.
_Stacks: {
	// Shared environments
	for name, stack in _SharedEnvironments {(name): stack}

	// Personal sandbox envrionemnts
	for name, stack in _SandboxEnvironments {(name): stack}
}

// Manage the stacks on all workload clusters.
for Cluster in #Fleets.workload.clusters {
	// For each bank of holos stack (dev, test, stage, prod, sandboxes)
	for Stack in _Stacks {
		// For each component composing the stack
		for Component in Stack.Components {
			// DEMO:ENVS ⓘ Stack components are added to the Platform here.
			#Platform: Components: "\(Cluster.name):\(Component.name)": {
				name:      Component.name
				component: Component.path
				tags:      Component.tags
				cluster:   Cluster.name
			}
		}
	}
}

// Environment represents the schema of a shared environment.
#Environment: {
	[NAME=string]: #StackTemplate & {Env: NAME}
}

// Sandbox represents the schema of a sandbox environment.
#Sandbox: {
	[NAME=string]: #StackTemplate & {Env: "sandbox", Owner: NAME}
}

// StackTemplate represents a template of the collection of components composing
// a stack and the tags to inject to each.  The first use case is to deploy the
// stack into four different environments, dev, test, staging, production.  The
// second use case is to deploy the stack for an individual developer, for
// example Bob joins the company and wants to deploy the stack into his own
// personal sandbox.
// DEMO:ENVS ⓘ StackTemplate to stamp out multiple copies of the stack.
#StackTemplate: {
	Env:   "dev" | "test" | "stage" | "prod" | "sandbox"
	Owner: string

	// Version represents the stack version, used to branch environments
	Version: string | *"v1"

	// Tags represents additional tags to inject, useful when developing a new
	// stack version.
	Tags: {[string]: string}

	// NamespacePrefix represents the namespace prefix for the stack.  The most
	// significant information should be on the left, which is the environment.
	// The second most significant piece of information is the sandbox owner, if
	// any.
	NamespacePrefix: string
	// HostPrefix represends the DNS host prefix, "" for prod
	HostPrefix: string

	Owners: {
		security: string
		backend:  string
		frontend: string
	}

	// Shared environments, parts of the stack are owned by teams.
	if Env != "sandbox" {
		NamespacePrefix: "\(Env)-"
		Owners: {
			security: "security"
			backend:  "backend"
			frontend: "frontend"
		}
	}

	// Personal environment, everything owned by the person.
	if Env == "sandbox" {
		NamespacePrefix: "\(Env)-\(Owner)-"
		Owners: {
			security: Owner
			backend:  Owner
			frontend: Owner
		}
	}

	if Env == "prod" {
		HostPrefix: ""
	}
	if Env != "prod" {
		HostPrefix: NamespacePrefix
	}

	// DEMO:ENVS ⓘ Stack template components organized by team
	Components: {
		"bank-projects":            Security
		"bank-namespaces":          Security
		"bank-secrets":             Security
		"bank-routes":              Security
		"bank-frontend":            Frontend
		"bank-backend-config":      Backend
		"bank-userservice":         Backend
		"bank-ledger-writer":       Backend
		"bank-balance-reader":      Backend
		"bank-transaction-history": Backend
		"bank-contacts":            Backend
		"bank-accounts-db":         Database
		"bank-ledger-db":           Database

		[NAME=string]: {
			name:    NamespacePrefix + NAME
			env:     Env
			owner:   string
			version: Version
			team:    "frontend" | "backend" | "security"
			tier:    "foundation" | "database" | "backend" | "web"
			// path to the source component
			path: "projects/bank-of-holos/\(version)/\(team)/components/\(NAME)"

			let OWNER = owner
			let TIER = tier

			// Tag variables to inject when rendering the component.
			tags: Tags & {
				owner:         OWNER
				environment:   Env
				tier:          TIER
				prefix:        NamespacePrefix
				host_prefix:   HostPrefix
				stack_version: version
			}
		}

		let Security = {owner: Owners.security, team: "security", tier: "foundation"}
		let Frontend = {owner: Owners.frontend, team: "frontend", tier: "web"}
		let Backend = {owner: Owners.backend, team: "backend", tier: string | *"backend"}
		let Database = Backend & {tier: "database"}
	}
}
