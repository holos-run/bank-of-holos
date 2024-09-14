package holos

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan

let Chart = {
	Name:      "cert-manager"
	Version:   #CertManager.Version
	Namespace: #CertManager.Namespace

	Repo: name: "jetstack"
	Repo: url:  "https://charts.jetstack.io"

	Values: installCRDs: true
	Values: startupapicheck: enabled: false
}
