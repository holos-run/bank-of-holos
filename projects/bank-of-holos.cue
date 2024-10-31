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

_BankOfHolos: #BankOfHolos & {
	Name: "bank-of-holos"

	Frontend: Namespace: "bank-frontend"
	Backend: Namespace:  "bank-backend"
	Security: Namespace: "bank-security"
}

// Register namespaces
_Namespaces: (_BankOfHolos.Frontend.Namespace): _
_Namespaces: (_BankOfHolos.Backend.Namespace):  _
_Namespaces: (_BankOfHolos.Security.Namespace): _

// Register projects
_AppProjects: {
	"bank-frontend": _
	"bank-backend":  _
	"bank-security": _
}

// Register HTTPRoutes.
// bank.example.com routes to Service frontend in the bank-frontend namespace.
_HTTPRoutes: bank: _backendRefs: frontend: namespace: _BankOfHolos.Frontend.Namespace
