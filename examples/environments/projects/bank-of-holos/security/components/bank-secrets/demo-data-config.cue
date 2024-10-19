package holos

import batchv1 "k8s.io/api/batch/v1"

// New secret generator jobs may be added by copying this file and changing only
// this name, then create the entrypoint script.
let SecretName = "demo-data-config"

// Register the secret for rbac rules.
_GeneratedSecrets: (SecretName): _

_Kubernetes: #Kubernetes & {
	KustomizeConfig: {
		Kustomization: {
			configMapGenerator: [{
				name: SecretName
				files: ["\(SecretName)/entrypoint"]
				options: disableNameSuffixHash: true
			}]
		}
		// Add all configMapGenerator files as Holos File generators, so they get
		// copied into place when Holos runs kustomize.
		for x in Kustomization.configMapGenerator {
			for file in x.files {
				Files: (file): _
			}
		}
	}

	Resources: {
		Job: (SecretName): batchv1.#Job & {
			spec: template: spec: #JobSpec & {
				_configMap: SecretName
			}
		}
	}
}
