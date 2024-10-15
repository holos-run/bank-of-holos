package holos

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan

let Chart = {
	Name:      "cert-manager"
	Namespace: #CertManager.Namespace

	Chart: {
		name:    Name
		version: #CertManager.Version
		release: Name
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
