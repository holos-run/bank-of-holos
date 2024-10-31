package holos

let COMPONENTS = {
	[NAME=string]: {name: NAME, owner: "security" | "frontend" | "backend"}

	"bank-secrets": owner:             "security"
	"bank-frontend": owner:            "frontend"
	"bank-backend-config": owner:      "backend"
	"bank-backend-config": owner:      "backend"
	"bank-accounts-db": owner:         "backend"
	"bank-userservice": owner:         "backend"
	"bank-ledger-db": owner:           "backend"
	"bank-ledger-writer": owner:       "backend"
	"bank-balance-reader": owner:      "backend"
	"bank-transaction-history": owner: "backend"
	"bank-contacts": owner:            "backend"
}

// Manage on workload clusters only
for Cluster in _Fleets.workload.clusters {
	for Component in COMPONENTS {
		_Platform: Components: "\(Cluster.name):\(Component.name)": {
			name:      Component.name
			component: "projects/bank-of-holos/\(Component.owner)/components/\(Component.name)"
			cluster:   Cluster.name
		}
	}
}
