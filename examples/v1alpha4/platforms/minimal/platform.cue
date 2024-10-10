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
			#Platform: Components: "\(Cluster.name):\(Env.name):namespaces": {
				name:        "\(Env.name)-namespaces"
				component:   "projects/platform/components/namespaces"
				cluster:     Cluster.name
				environment: Env.name
			}
		}
	}
}
