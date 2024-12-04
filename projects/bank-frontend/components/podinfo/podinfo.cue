package holos

holos: Podinfo.BuildPlan

// Reference the correct environment namespace for frontend applications
_namespace: BankOfHolos.configuration.environments[EnvironmentName].frontend.namespace

Podinfo: #Helm & {
	Name: "podinfo"
    Namespace: _namespace
    // Ensure metadata.namespace is added to all resources with kustomize.
	KustomizeConfig: Kustomization: namespace: _namespace
	Chart: {
		version: "6.6.2"
		repository: {
			name: "podinfo"
			url:  "https://stefanprodan.github.io/podinfo"
		}
	}

    // List comprehension acting as a Switch statement: https://cuetorials.com/patterns/switch/
    // Use 3 replicas in prod, and 1 in all other environments
    Values: replicaCount: [
        if EnvironmentName =~ "^prod" {3},
        1,
    ][0] // Select the first element in the list
}
