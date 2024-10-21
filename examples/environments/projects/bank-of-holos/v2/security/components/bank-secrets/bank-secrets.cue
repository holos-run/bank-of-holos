package holos

import (
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
)

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

// Roles for reading and writing secrets
let Reader = "bank-secrets-reader"
let Writer = "bank-secrets-writer"

// Registration point for role bindings
_GeneratedSecrets: [NAME=string]: {name: NAME}

// DEMO:SECRETS ⓘ JobSpec for secret generators.
#JobSpec: {
	_configMap:         string
	serviceAccountName: Writer
	restartPolicy:      string | *"OnFailure"
	securityContext: {
		seccompProfile: type: "RuntimeDefault"
		runAsNonRoot: true
		runAsUser:    8192 // app
	}
	containers: [
		{
			name:  "toolkit"
			image: "quay.io/holos-run/toolkit:2024-10-19"
			securityContext: {
				capabilities: drop: ["ALL"]
				allowPrivilegeEscalation: false
			}
			command: ["/bin/bash"]
			args: ["/config/entrypoint"]
			env: [{
				name:  "HOME"
				value: "/tmp"
			}]
			volumeMounts: [{
				name:      "config"
				mountPath: "/config"
				readOnly:  true
			}]
		},
	]
	volumes: [{
		name: "config"
		configMap: name: _configMap
	}]
}

// AllowedName represents the service account allowed to read the generated
// secret.
let AllowedName = _Stack.BankName

_Kubernetes: #Kubernetes & {
	Namespace: _Stack.Security.Namespace

	KustomizeConfig: {
		Kustomization: {
			// Hidden struct to register config map generators
			_configMapGenerators: {
				[NAME=string]: {
					name: NAME
					_files: {[FILE=string]: file: FILE}
					_files: "\(NAME)/entrypoint": _
					files: [for x in _files {x.file}]
					options: disableNameSuffixHash: true
				}
			}
			// Build the list once
			configMapGenerator: [for x in _configMapGenerators {x}]
		}
		// Add all configMapGenerator files as Holos File generators, so they get
		// copied into place when Holos runs kustomize.
		for x in Kustomization.configMapGenerator {
			for file in x.files {
				Files: (file): _
			}
		}
	}

	Resources: [_]: [_]: metadata: namespace:    Namespace
	Resources: [_]: [ID=string]: metadata: name: string | *ID

	Resources: {
		// Kubernetes ServiceAccount used by the secret generator job.
		ServiceAccount: (Writer): corev1.#ServiceAccount
		// Role to allow the ServiceAccount to update secrets.
		Role: (Writer): rbacv1.#Role & {
			rules: [{
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["create", "update", "patch"]
			}]
		}
		// Bind the role to the service account.
		RoleBinding: (Writer): rbacv1.#RoleBinding & {
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "Role"
				name:     Role[Writer].metadata.name
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      ServiceAccount[Writer].metadata.name
				namespace: Namespace
			}]
		}

		// DEMO:SECRETS ⓘ Role to allow SecretStore read access.
		// Allow the SecretStore in the frontend and backend namespaces to read the
		// secret.
		Role: (Reader): rbacv1.#Role & {
			rules: [{
				apiGroups: [""]
				resources: ["secrets"]
				resourceNames: [for x in _GeneratedSecrets {x.name}]
				verbs: ["get"]
			}]
		}

		// Grant access to the bank-of-holos service account in the frontend and
		// backend namespaces.
		RoleBinding: (Reader): rbacv1.#RoleBinding & {
			roleRef: {
				apiGroup: "rbac.authorization.k8s.io"
				kind:     "Role"
				name:     Role[Reader].metadata.name
			}
			subjects: [{
				kind:      "ServiceAccount"
				name:      AllowedName
				namespace: _Stack.Frontend.Namespace
			}, {
				kind:      "ServiceAccount"
				name:      AllowedName
				namespace: _Stack.Backend.Namespace
			},
			]
		}

	}
}
