package holos

import batchv1 "k8s.io/api/batch/v1"

_Kubernetes: #Kubernetes & {
	KustomizeConfig: {
		Kustomization: {
			configMapGenerator: [{
				name: "gen-testuser"
				files: ["gen-testuser/entrypoint"]
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
		Job: "gen-testuser": batchv1.#Job & {
			spec: template: spec: #JobSpec & {
				_configMap: "gen-testuser"
			}
		}
	}
}
