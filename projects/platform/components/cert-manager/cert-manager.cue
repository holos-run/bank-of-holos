package holos

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan

let Chart = {
	Name:      "cert-manager"
	Namespace: #CertManager.Namespace

	Chart: {
		version: #CertManager.Version
		repository: {
			name: "jetstack"
			url:  "https://charts.jetstack.io"
		}
	}

	Values: {
		installCRDs: true
		startupapicheck: enabled: false
	}
}
