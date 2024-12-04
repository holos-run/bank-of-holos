package holos

holos: Component.BuildPlan

Component: #Kubernetes & {
	// Look up the frontend namespace.
	Namespace: BankOfHolos.configuration.environments[EnvironmentName].frontend.namespace

	// Ensure resources go in the correct namespace.
	Resources: [_]: [_]: metadata: namespace: Namespace

	Resources: {
    Project:
  }
}
