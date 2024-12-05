@if(!NoBank)
package holos

TierName: string @tag(TierName)

// Platform wide configuration.
BankOfHolos: #BankOfHolos & {
	Name: string | *"bank-of-holos"

	Environments: {
		dev: tier:         "nonprod"
		test: tier:        "nonprod"
		stage: tier:       "nonprod"
		"prod-east": tier: "prod"
		"prod-west": tier: "prod"
	}

	Tiers: [NAME=string]: {
		name: NAME
		environments: [NAME=string]: #Environment
	}

	for ENV in Environments {
		Tiers: (ENV.tier): environments: (ENV.name): ENV
	}

	#BankProject: #Project & {
		_kargo_cluster_projects: {[CLUSTER=string]: [NAME=string]: metadata: name: NAME}
	}

	// TODO(jeff): Split into prod and nonprod project sets as Gary suggested.
	for TIER in BankOfHolos.configuration.tiers {
		let BankSecurity = "\(TIER.name)-bank-security"
		let BankBackend = "\(TIER.name)-bank-backend"
		let BankWeb = "\(TIER.name)-bank-web"

		Projects: {
			(BankSecurity): #BankProject & {
				name:     _
				clusters: ClusterSets.workload.clusters
				team:     "security"
				// And one special namespace for the Kargo Project for this Holos Project.
				// https://docs.kargo.io/how-to-guides/working-with-projects#namespace-adoption
				let KargoAdopt = {metadata: labels: "kargo.akuity.io/project": "true"}
				namespaces: (BankSecurity): KargoAdopt
				namespaces: (BankBackend):  KargoAdopt
				namespaces: (BankWeb):      KargoAdopt

				// The security team manages the environment namespaces for the whole stack.
				for CLUSTER in clusters {
					_kargo_cluster_projects: (CLUSTER.name): (BankSecurity): _
					_kargo_cluster_projects: (CLUSTER.name): (BankBackend):  _
					_kargo_cluster_projects: (CLUSTER.name): (BankWeb):      _

					let NAMESPACES = #SharedComponent & {
						_component: "namespaces"
						_project:   name
						_cluster:   CLUSTER.name
						_team:      team
						_stack:     Name
					}
					components: (NAMESPACES.name): NAMESPACES.component

					// The projects component digs into Projects.foo._kargo_cluster_projects
					// to configure Kargo Project resources.
					let PROJECTS = #SharedComponent & {
						_component: "projects"
						_project:   name
						_cluster:   CLUSTER.name
						_team:      team
						_stack:     Name
					}
					components: (PROJECTS.name): PROJECTS.component

					// The stages component digs into Projects.foo._kargo_cluster_projects
					// to configure Kargo warehouses and stages for the project.
					let STAGES = #ProjectClusterComponent & {
						_component: "stages"
						_project:   name
						_cluster:   CLUSTER.name
						_team:      team
						_stack:     Name
						component: path: "./projects/bank-security/components/stages"
						component: parameters: TierName: TIER.name
					}
					components: (STAGES.name): STAGES.component

					for ENV in Tiers[TIER.name].environments {
						namespaces: BankOfHolos.configuration.environments[ENV.name].namespaces

						let BUILDER = #ProjectClusterComponent & {
							_project:     name
							_cluster:     CLUSTER.name
							_environment: ENV.name
							_team:        team
							_stack:       Name
						}
						let SECRETS = BUILDER & {
							_component: "\(ENV.name)-secrets"
							component: path: "projects/security/components/bank-secrets"
						}
						components: (SECRETS.name): SECRETS.component
					}
				}
			}

			(BankBackend): {
				name:     _
				clusters: ClusterSets.workload.clusters
				team:     "backend"

				for CLUSTER in clusters {
					for ENV in Tiers[TIER.name].environments {
						let BUILDER = #ProjectClusterComponent & {
							_project:     name
							_cluster:     CLUSTER.name
							_environment: ENV.name
							_team:        team
							_stack:       Name
						}

						// Configuration
						let CONFIG = BUILDER & {
							_component: "\(ENV.name)-bank-backend-config"
							component: path: "projects/bank-backend/components/bank-backend-config"
						}
						components: (CONFIG.name): CONFIG.component

						// Databases
						let ACCOUNTS_DB = BUILDER & {
							_component: "\(ENV.name)-accounts-db"
							component: path: "projects/bank-backend/components/bank-accounts-db"
						}
						components: (ACCOUNTS_DB.name): ACCOUNTS_DB.component

						let LEDGER_DB = BUILDER & {
							_component: "\(ENV.name)-ledger-db"
							component: path: "projects/bank-backend/components/bank-ledger-db"
						}
						components: (LEDGER_DB.name): LEDGER_DB.component

						// Services
						let CONTACTS = BUILDER & {
							_component: "\(ENV.name)-contacts"
							component: path: "projects/bank-backend/components/bank-contacts"
						}
						components: (CONTACTS.name): CONTACTS.component

						let BALANCE_READER = BUILDER & {
							_component: "\(ENV.name)-balance-reader"
							component: path: "projects/bank-backend/components/bank-balance-reader"
						}
						components: (BALANCE_READER.name): BALANCE_READER.component

						let USERSERVICE = BUILDER & {
							_component: "\(ENV.name)-userservice"
							component: path: "projects/bank-backend/components/bank-userservice"
						}
						components: (USERSERVICE.name): USERSERVICE.component

						let LEDGER_WRITER = BUILDER & {
							_component: "\(ENV.name)-ledger-writer"
							component: path: "projects/bank-backend/components/bank-ledger-writer"
						}
						components: (LEDGER_WRITER.name): LEDGER_WRITER.component

						let TRANSACTION_HISTORY = BUILDER & {
							_component: "\(ENV.name)-transaction-history"
							component: path: "projects/bank-backend/components/bank-transaction-history"
						}
						components: (TRANSACTION_HISTORY.name): TRANSACTION_HISTORY.component
					}
				}
			}

			(BankWeb): {
				name:     _
				clusters: ClusterSets.workload.clusters
				team:     "frontend"

				for CLUSTER in clusters {
					for ENV in Tiers[TIER.name].environments {
						let BUILDER = #ProjectClusterComponent & {
							_project:     name
							_cluster:     CLUSTER.name
							_environment: ENV.name
							_team:        team
							_stack:       Name
						}

						// Web Frontend
						let FRONTEND = BUILDER & {
							_component: "\(ENV.name)-frontend"
							component: path: "projects/bank-frontend/components/bank-frontend"
						}
						components: (FRONTEND.name): FRONTEND.component
					}
				}
			}
		}
	}
}

// Register the bank projects with the platform.
Projects: BankOfHolos.Projects

// prod httproutes
for NS in BankOfHolos.configuration.tiers.prod.frontend.namespaces {
	// Split traffic between east and west, like a global load balancer.
	// https://bank.holos.localhost
	HTTPRoutes: bank: _backendRefs: (NS.name): {
		name:      "frontend"
		namespace: NS.name
	}
	// Route traffic to regional backend.
	// https://prod-east-bank-frontend.holos.localhost
	// https://prod-west-bank-frontend.holos.localhost
	HTTPRoutes: (NS.name): _backendRefs: frontend: namespace: NS.name
}

// nonprod httproutes
for ENV in BankOfHolos.configuration.tiers.nonprod.environments {
	let NAMESPACE = BankOfHolos.configuration.environments[ENV.name].frontend.namespace
	HTTPRoutes: "\(ENV.name)-bank": _backendRefs: frontend: namespace: NAMESPACE
}

// Platform wide schema definition.
#BankOfHolos: {
	Name: string
	// Holos Projects, oriented to Kargo Projects
	Projects: #Projects

	// Environments to manage in each project.
	Environments: #Environments

	// Environments organized by tiers.
	Tiers: [NAME=string]: {name: NAME, environments: #Environments}

	// Configuration constructed from the above fields.
	configuration: {
		tiers: [NAME=string]: {
			name: NAME
			frontend: namespaces: [NAME=string]: name: NAME
			environments: #Environments
		}

		// Map environments to their tier.
		for ENV in environments {
			tiers: (Environments[ENV.name].tier): {
				frontend: namespaces: (ENV.frontend.namespace): _
				environments: (ENV.name): Environments[ENV.name]
			}
		}

		environments: [NAME=string]: {
			name: NAME
			frontend: namespace: "\(NAME)-bank-frontend"
			backend: namespace:  "\(NAME)-bank-backend"
			security: namespace: "\(NAME)-bank-security"
			namespaces: #Namespaces & {
				(frontend.namespace): _
				(backend.namespace):  _
				(security.namespace): _
			}
		}
		for ENV in Environments {
			environments: (ENV.name): _
		}
	}
}
