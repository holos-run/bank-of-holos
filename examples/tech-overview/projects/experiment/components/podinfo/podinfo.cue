package holos

// Produce a helm chart build plan.
_HelmChart.BuildPlan

_HelmChart: #Helm & {
	Name: "podinfo"
	Chart: {
		version: "6.6.2"
		repository: {
			name: "podinfo"
			url:  "https://stefanprodan.github.io/podinfo"
		}
	}
}
