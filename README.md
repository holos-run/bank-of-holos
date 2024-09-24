# Bank of Holos

**Bank of Holos** is an example software development platform built for a
*fictional retail bank using [Holos].  Holos is an open source tool that makes
*it easier and safer to manage a software development platform.

The Holos Authors use this repository to show how platform, security, and dev
teams build golden paths for each other.  Teams deliver services safer, easier,
and more consistently with Holos and these golden paths.  This repository is
used extensively in our [Guides] to apply the configuration to a real Kubernetes cluster.

## Get Started

1. Read the [Quickstart] to learn the core concepts of Holos and see how to re-use an existing Helm chart.
2. Create a [Local Cluster] to apply our guides to your local machine.
3. [Deploy a Service] explores how the platform team at the bank provides golden paths for a dev team to migrate a service from an acquired company.
3. [Change a Service] walks through a common Day 2 task, making a simple
configuration change to a web app.

## Screenshots

<details><summary>Expand

```
holos render platform ./platform
```

</summary>

```
rendered bank-accounts-db for cluster workload in 160.7245ms
rendered bank-ledger-db for cluster workload in 162.465625ms
rendered bank-userservice for cluster workload in 166.150417ms
rendered bank-ledger-writer for cluster workload in 168.075459ms
rendered bank-balance-reader for cluster workload in 172.492292ms
rendered bank-backend-config for cluster workload in 198.117916ms
rendered bank-secrets for cluster workload in 223.200042ms
rendered gateway for cluster workload in 124.841917ms
rendered httproutes for cluster workload in 131.86625ms
rendered bank-contacts for cluster workload in 154.463792ms
rendered bank-transaction-history for cluster workload in 159.968208ms
rendered bank-frontend for cluster workload in 325.24425ms
rendered app-projects for cluster workload in 110.577916ms
rendered ztunnel for cluster workload in 137.502792ms
rendered cni for cluster workload in 209.993375ms
rendered cert-manager for cluster workload in 172.933834ms
rendered external-secrets for cluster workload in 135.759792ms
rendered local-ca for cluster workload in 98.026708ms
rendered istiod for cluster workload in 403.050833ms
rendered argocd for cluster workload in 294.663167ms
rendered gateway-api for cluster workload in 228.47875ms
rendered namespaces for cluster workload in 113.586916ms
rendered base for cluster workload in 533.76675ms
rendered external-secrets-crds for cluster workload in 529.053375ms
rendered crds for cluster workload in 931.180458ms
rendered platform in 1.248310167s
```
</details>


| Bank Home                                                        | GitOps                                                            |
| ---------------------------------------------------------------- | ----------------------------------------------------------------- |
| [![Bank Home](/docs/img/bank-home.png)](/docs/img/bank-home.png) | [![GitOps](/docs/img/bank-argocd.png)](/docs/img/bank-argocd.png) |


[Holos]: https://holos.run
[Quickstart]: https://holos.run/docs/quickstart/
[Guides]: https://holos.run/docs/guides/
[Local Cluster]: https://holos.run/docs/guides/local-cluster/
[Deploy a Service]: https://holos.run/docs/guides/deploy-a-service/
[Change a Service]: https://holos.run/docs/guides/change-a-service/
