package holos

// Produce a helm chart build plan.
_HelmChart.BuildPlan

_HelmChart: #Helm & {
	Name:      "cert-manager"
	Namespace: _CertManager.Namespace

	Chart: {
		version: _CertManager.Version
		repository: {
			name: "jetstack"
			url:  "https://charts.jetstack.io"
		}
	}
	EnableHooks: true

	Values: #Values & {
		crds: enabled:            true
		startupapicheck: enabled: false
		// https://github.com/cert-manager/cert-manager/issues/6716
		global: leaderElection: namespace: Namespace
	}
}
