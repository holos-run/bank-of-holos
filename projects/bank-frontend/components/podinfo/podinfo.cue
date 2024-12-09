package holos

holos: Podinfo.BuildPlan

// Access Namespace and Tier from BankOfHolos field defined in the root of the repository.
_namespace: BankOfHolos.configuration.environments[EnvironmentName].frontend.namespace
_tier: BankOfHolos.Environments[EnvironmentName].tier

Podinfo: #Helm & {
    Namespace: _namespace
    // Ensure metadata.namespace is added to all resources with kustomize.
    KustomizeConfig: Kustomization: namespace: _namespace
    Chart: {
        name: "podinfo"
        version: "6.6.2"
        repository: {
            name: "podinfo"
            url: "https://stefanprodan.github.io/podinfo"
        }
    }

    // Schema to specify chart values based on the cluster's tier (e.g. prod or nonprod)
    #TierValues: [TIER=string]: replicaCount: int & >=0

    // Use 3 replicas in prod, and 1 in all nonprod environments
    let TIERVALUES = #TierValues & {
        nonprod: replicaCount: 1
        prod: replicaCount: 3
    }

    // Provide all tier-specific Helm chart values via Chart.Values
    Values: TIERVALUES[_tier]
}
