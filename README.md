# Bank of Holos

Bank of Holos is an example software development platform built for a fictional
retail bank using [Holos].  Holos is an open source tool that makes it easier
and safer to manage a software development platform.

The Holos Authors use this repository to showcase core features and
integrations.

## Get Started

1. Read the [Tutorial] to learn the core concepts of Holos and see how to re-use
an existing Helm chart.
2. Create a [Local Cluster] to apply our guides to your local machine.

## Screenshots

<details><summary>Expand

```
holos render platform -t k3d -t NoValidate
```

</summary>

```
rendered namespaces for project argocd on cluster management in 175.497792ms
rendered istio-gateway for project network on cluster management in 187.160583ms
rendered app-projects for project argocd on cluster management in 190.721584ms
rendered namespaces for project network on cluster management in 216.181375ms
rendered istio-cni for project network on cluster management in 220.544167ms
rendered namespaces for project argocd on cluster workload in 222.873625ms
rendered istio-ztunnel for project network on cluster management in 241.792375ms
rendered app-projects for project argocd on cluster workload in 241.7655ms
rendered istiod for project network on cluster management in 273.464333ms
rendered namespaces for project network on cluster workload in 163.81125ms
rendered argocd for project argocd on cluster management in 370.687ms
rendered istio-ztunnel for project network on cluster workload in 190.925875ms
rendered istio-gateway for project network on cluster workload in 191.488541ms
rendered istio-cni for project network on cluster workload in 233.898667ms
rendered istiod for project network on cluster workload in 246.182ms
rendered argocd for project argocd on cluster workload in 486.03525ms
rendered httproutes for project network on cluster workload in 215.790916ms
rendered gateway-api for project network on cluster management in 386.926542ms
rendered istio-base for project network on cluster management in 590.229708ms
rendered httproutes for project network on cluster management in 418.295791ms
rendered local-ca for project security on cluster management in 173.987709ms
rendered namespaces for project security on cluster management in 272.365667ms
rendered external-secrets for project security on cluster management in 211.616792ms
rendered namespaces for project security on cluster workload in 179.023334ms
rendered gateway-api for project network on cluster workload in 321.226667ms
rendered local-ca for project security on cluster workload in 141.685875ms
rendered argocd-crds for project argocd on cluster management in 765.814875ms
rendered argocd-crds for project argocd on cluster workload in 765.849917ms
rendered external-secrets for project security on cluster workload in 191.581834ms
rendered istio-base for project network on cluster workload in 559.672917ms
rendered external-secrets-crds for project security on cluster management in 399.3295ms
rendered cert-manager for project security on cluster management in 381.171416ms
rendered external-secrets-crds for project security on cluster workload in 416.113958ms
rendered cert-manager for project security on cluster workload in 351.827416ms
rendered platform in 942.248666ms
holos render platform -t k3d -t NoValidate  9.10s user 1.88s system 1054% cpu 1.041 total
```
</details>


| Bank Home                                                        | GitOps                                                            |
| ---------------------------------------------------------------- | ----------------------------------------------------------------- |
| [![Bank Home](/docs/img/bank-home.png)](/docs/img/bank-home.png) | [![GitOps](/docs/img/bank-argocd.png)](/docs/img/bank-argocd.png) |


[Holos]: https://holos.run
[Tutorial]: https://holos.run/docs/v1alpha5/tutorial/overview/
[Local Cluster]: https://holos.run/docs/guides/local-cluster/
