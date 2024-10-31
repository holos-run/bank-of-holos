package holos

// Produce a helm chart build plan.
_Helm.BuildPlan

_Helm: #Helm & {
	Name:      "istio-ztunnel"
	Namespace: _Istio.System.Namespace

	Chart: {
		name:    "ztunnel"
		version: _Istio.Version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
	}

	Values: _Istio.Values
}
