package holos

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan

let Chart = {
	Name:      "istio-ztunnel"
	Namespace: #Istio.System.Namespace

	Chart: {
		name:    "ztunnel"
		version: #Istio.Version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
	}

	Values: #Istio.Values
}
