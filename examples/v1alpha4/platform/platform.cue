package holos

_Environments: [NAME=_]: {name: NAME}
_Environments: {
	dev:   _
	test:  _
	stage: _
	prod:  _
}

// Manage the component on every Cluster in the Platform
for Fleet in #Fleets {
	for Cluster in Fleet.clusters {
		for Env in _Environments {
			// Resources + Kustomize test
			#Platform: Components: "\(Cluster.name):\(Env.name):namespaces": {
				name:        "\(Env.name)-namespaces"
				component:   "projects/platform/components/namespaces"
				cluster:     Cluster.name
				environment: Env.name
			}

			// Join transformer test
			#Platform: Components: "\(Cluster.name):\(Env.name):join": {
				name:        "\(Env.name)-join"
				component:   "projects/tests/join"
				cluster:     Cluster.name
				environment: Env.name
			}

			// Helm + Kustomize test (traditional helm repo)
			#Platform: Components: "\(Cluster.name):\(Env.name):podinfo": {
				name:        "\(Env.name)-podinfo"
				component:   "projects/tests/podinfo"
				cluster:     Cluster.name
				environment: Env.name
			}
		}
	}
}
