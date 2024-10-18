package holos

let Stacks = {
	// Shared environments
	dev:   (StackTemplate & {Env: "dev"}).Stack
	test:  (StackTemplate & {Env: "test"}).Stack
	stage: (StackTemplate & {Env: "stage"}).Stack
	prod:  (StackTemplate & {Env: "prod"}).Stack
	// Personal sandbox envrionemnts
	jeff: (StackTemplate & {Env: "sandbox", Owner: "jeff"}).Stack
	gary: (StackTemplate & {Env: "sandbox", Owner: "gary"}).Stack
	nate: (StackTemplate & {Env: "sandbox", Owner: "nate"}).Stack
}

// Manage the stacks on all workload clusters.
for Cluster in #Fleets.workload.clusters {
	// For each bank of holos stack (dev, test, stage, prod, sandboxes)
	for Stack in Stacks {
		// For each component composing the stack
		for Component in Stack.Components {
			#Platform: Components: "\(Cluster.name):\(Component.name)": {
				name:      Component.name
				component: Component.path
				tags:      Component.tags
				cluster:   Cluster.name
			}
		}
	}
}

// StackTemplate represents a template of the collection of components composing
// a stack and the tags to inject to each.  The first use case is to deploy the
// stack into four different environments, dev, test, staging, production.  The
// second use case is to deploy the stack for an individual developer, for
// example Bob joins the company and wants to deploy the stack into his own
// personal sandbox.
let StackTemplate = {
	Env:   "dev" | "test" | "stage" | "prod" | "sandbox"
	Owner: string

	// NamespacePrefix represents the namespace prefix for the stack.  The most
	// significant information should be on the left, which is the environment.
	// The second most significant piece of information is the sandbox owner, if
	// any.
	NamespacePrefix: string

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

	Stack: {
		Components: {
			[NAME=string]: {
				name:  NamespacePrefix + NAME
				env:   Env
				owner: string
				tier:  string
				// the path to the source component
				path: "projects/bank-of-holos/\(tier)/components/\(NAME)"

				let OWNER = owner
				let TIER = tier

				// Tags to inject
				tags: owner:       OWNER
				tags: environment: Env
				tags: prefix:      NamespacePrefix
				tags: tier:        TIER
			}

			let Security = {owner: Owners.security, tier: "security"}
			let Frontend = {owner: Owners.frontend, tier: "frontend"}
			let Backend = {owner: Owners.backend, tier: "backend"}

			"bank-namespaces":     Security
			"bank-secrets":        Security
			"bank-frontend":       Frontend
			"bank-backend-config": Backend
			"bank-accounts-db":    Backend
			// "bank-userservice":         Backend
			// "bank-ledger-db":           Backend
			// "bank-ledger-writer":       Backend
			// "bank-balance-reader":      Backend
			// "bank-transaction-history": Backend
			// "bank-contacts":            Backend
		}
	}
}
