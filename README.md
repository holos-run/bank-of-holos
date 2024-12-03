# Bank of Holos

Bank of Holos is an example software development platform built for a fictional
retail bank using [Holos].  Holos is an open source tool that makes it easier
and safer to manage a software development platform.

The Holos Authors use this repository to showcase core features and
integrations.

## Get Started

1. Read the [Quickstart] to learn the core concepts of Holos.
2. Create a [local cluster] to explore this repository on your local device.

## Screenshots

Render the platform configuration for a k3d [local cluster].

```shell
holos render platform -t k3d
```

Apply the platform configuration to the local cluster using [scripts/apply].

```shell
./scripts/apply
```

| Bank Home                                                        | GitOps                                                            |
| ---------------------------------------------------------------- | ----------------------------------------------------------------- |
| [![Bank Home](/docs/img/bank-home.png)](/docs/img/bank-home.png) | [![GitOps](/docs/img/bank-argocd.png)](/docs/img/bank-argocd.png) |

[Holos]: https://holos.run
[Quickstart]: https://holos.run/docs/quickstart/
[local cluster]: https://holos.run/docs/local-cluster/
[scripts/apply]: ./scripts/apply
