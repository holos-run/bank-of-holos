package holos

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "kargo"
	Namespace: Kargo.Namespace

	Chart: {
		name:    "oci://ghcr.io/akuity/kargo-charts/kargo"
		version: "1.0.3"
		release: Name
	}
	EnableHooks: true

	Values: Kargo.Values
}
