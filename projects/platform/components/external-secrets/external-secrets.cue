package holos

let Chart = {
	Name:      "external-secrets"
	Namespace: "external-secrets"

	Chart: {
		version: "0.10.3"
		repository: {
			name: "external-secrets"
			url:  "https://charts.external-secrets.io"
		}
	}

	Values: installCRDs: false
}

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan
