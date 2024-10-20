package holos

import batchv1 "k8s.io/api/batch/v1"

// New secret generator jobs may be added by copying this file and changing only
// this name, then create the entrypoint script.
let SecretName = "ledger-db-config"

// Register the secret for rbac rules.
_GeneratedSecrets: (SecretName): _

_Kubernetes: #Kubernetes & {
	KustomizeConfig: Kustomization: _configMapGenerators: (SecretName): _

	Resources: {
		Job: (SecretName): batchv1.#Job & {
			spec: template: spec: #JobSpec & {
				_configMap: SecretName
			}
		}
	}
}
