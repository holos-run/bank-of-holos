package holos

import (
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
	batchv1 "k8s.io/api/batch/v1"
)

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

// This may be useful to copy and generate other secrets.
let SecretName = "jwt-key"

// Roles for reading and writing secrets
let Reader = "\(SecretName)-reader"
let Writer = "\(SecretName)-writer"

#JobSpec: {
	_configMap:         string
	serviceAccountName: Writer
	restartPolicy:      "OnFailure"
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

		Job: (Writer): batchv1.#Job & {
			spec: template: spec: #JobSpec & {
				_configMap: Writer
			}
		}

		Job: (Writer): batchv1.#Job & {
			spec: template: spec: #JobSpec & {
				_configMap: Writer
			}
		}

		ConfigMap: (Writer): corev1.#ConfigMap & {
			data: entrypoint: ENTRYPOINT
		}

		// Allow the SecretStore in the frontend and backend namespaces to read the
		// secret.
		Role: (Reader): rbacv1.#Role & {
			rules: [{
				apiGroups: [""]
				resources: ["secrets"]
				resourceNames: [SecretName]
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

let ENTRYPOINT = """
	#! /bin/bash
	#

	tmpdir="$(mktemp -d)"
	finish() {
	  status=$?
	  rm -rf "${tmpdir}"
	  return $status
	}
	trap finish EXIT

	set -euo pipefail

	cd "$tmpdir"
	mkdir secret
	cd secret

	echo "generating private key" >&2
	ssh-keygen -t rsa -b 4096 -m PEM -f jwtRS256.key -q -N "" -C \(AllowedName)
	echo "generating public key" >&2
	ssh-keygen -e -m PKCS8 -f jwtRS256.key > jwtRS256.key.pub
	cd ..

	echo "copying secret into kubernetes manifest secret.yaml" >&2
	kubectl create secret generic \(SecretName) --from-file=secret --dry-run=client -o yaml > secret.yaml

	echo "applying secret.yaml" >&2
	kubectl apply --server-side=true -f secret.yaml

	echo "cleaning up" >&2
	rm -rf secret secret.yaml

	echo "ok done" >&2
	"""
