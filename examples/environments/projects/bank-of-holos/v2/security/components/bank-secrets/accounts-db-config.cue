package holos

import batchv1 "k8s.io/api/batch/v1"

// New secret generator jobs may be added by copying this file and changing only
// this name, then create the entrypoint script.
let SecretName = "accounts-db-config"

// Register the secret for rbac rules.
_GeneratedSecrets: (SecretName): _

_Kubernetes: #Kubernetes & {
	// Copy the 1-load-testadata.sh script in additon to the entrypoint so the
	// generator Job can include the custom load script in the secret.
	// We need this to replace the hard-coded secret in the upstream container
	// by mounting the secript into /docker-entrypoint-initdb.d/1-load-testdata.sh
	KustomizeConfig: Kustomization: _configMapGenerators: (SecretName): _files: "\(SecretName)/1-load-testdata.sh": _

	Resources: {
		Job: (SecretName): batchv1.#Job & {
			spec: template: spec: #JobSpec & {
				_configMap: SecretName
			}
		}
	}
}
