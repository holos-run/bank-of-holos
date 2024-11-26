package holos

// Platform wide definitions
#BankOfHolos: {
	Name: string
	Frontend: Namespace: string
	Backend: Namespace:  string
	Security: Namespace: string

	// Resources to manage in each of the namespaces.
	Resources: #Resources
}

BankOfHolos: #BankOfHolos & {
	Name: "bank-of-holos"

	Frontend: Namespace: "bank-frontend"
	Backend: Namespace:  "bank-backend"
	Security: Namespace: "bank-security"
}

// Register namespaces
Namespaces: (BankOfHolos.Frontend.Namespace): _
Namespaces: (BankOfHolos.Backend.Namespace):  _
Namespaces: (BankOfHolos.Security.Namespace): _

// Register projects
AppProjects: {
	"bank-frontend": _
	"bank-backend":  _
	"bank-security": _
}

// Register HTTPRoutes.
// bank.example.com routes to Service frontend in the bank-frontend namespace.
_HTTPRoutes: bank: _backendRefs: frontend: namespace: BankOfHolos.Frontend.Namespace
