package holos

import (
	k8s "k8s.io/api/core/v1"
	es "external-secrets.io/externalsecret/v1beta1"
	ss "external-secrets.io/secretstore/v1beta1"
)

// _Stack represents resources within the context of the stack, which is
// deployed to an environment and has an owner.
_Stack: {
	BankName: string | *"bank-of-holos"

	Tags: {
		owner:       string @tag(owner, type=string)
		environment: string @tag(environment, type=string)
		tier:        string @tag(tier, type=string)
		// prefix represents the resource prefix.
		prefix:      string @tag(prefix, type=string)
		host_prefix: string @tag(host_prefix, type=string)
	}

	Environment: Tags.environment

	Frontend: Namespace: "\(Tags.prefix)bank-frontend"
	Backend: Namespace:  "\(Tags.prefix)bank-backend"
	Security: Namespace: "\(Tags.prefix)bank-security"

	Namespaces: {
		[Name=string]: k8s.#Namespace & {
			metadata: name: Name
		}

		(Frontend.Namespace): _
		(Backend.Namespace):  _
		(Security.Namespace): _
	}

	AppProject: [NAME=string]: AppProjects[NAME]

	AppProjects: #AppProjects & {
		"\(Tags.prefix)bank-frontend": _
		"\(Tags.prefix)bank-backend":  _
		"\(Tags.prefix)bank-security": _
	}

	// HTTPRoutes for each stack.
	HTTPRoutes: #HTTPRoutes & {
		"\(Tags.host_prefix)bank": _backendRefs: frontend: namespace: Frontend.Namespace
	}

	// Resources to make available in each of the namespaces.
	Resources: {
		ServiceAccount: (BankName): k8s.#ServiceAccount & {
			apiVersion: "v1"
			kind:       "ServiceAccount"
			metadata: name: BankName
		}

		// SecretStore to fetch secrets owned by the security team
		SecretStore: (BankName): ss.#SecretStore & {
			metadata: name: Security.Namespace
			spec: provider: {
				kubernetes: {
					remoteNamespace: Security.Namespace
					auth: serviceAccount: name: ServiceAccount[BankName].metadata.name
					server: {
						url: "https://kubernetes.default.svc"
						caProvider: {
							type: "ConfigMap"
							name: "kube-root-ca.crt"
							key:  "ca.crt"
						}
					}
				}
			}
		}

		// We do not check the private key into version control.
		// https://github.com/GoogleCloudPlatform/bank-of-anthos/tree/v0.6.5/extras/jwt
		ExternalSecret: "jwt-key": es.#ExternalSecret & {
			metadata: name: "jwt-key"
			spec: {
				target: name: metadata.name
				dataFrom: [{extract: {key: metadata.name}}]
				refreshInterval: "5s"
				secretStoreRef: kind: "SecretStore"
				secretStoreRef: name: SecretStore[BankName].metadata.name
			}
		}

		// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests/config.yaml
		ConfigMap: "environment-config": k8s.#ConfigMap & {
			apiVersion: "v1"
			kind:       "ConfigMap"
			metadata: name: "environment-config"
			data: {
				LOCAL_ROUTING_NUM: "883745000"
				PUB_KEY_PATH:      "/tmp/.ssh/publickey"
			}
		}

		ConfigMap: "service-api-config": k8s.#ConfigMap & {
			apiVersion: "v1"
			kind:       "ConfigMap"
			metadata: name: "service-api-config"
			data: {
				TRANSACTIONS_API_ADDR: "ledgerwriter.\(Backend.Namespace).svc:8080"
				BALANCES_API_ADDR:     "balancereader.\(Backend.Namespace).svc:8080"
				HISTORY_API_ADDR:      "transactionhistory.\(Backend.Namespace).svc:8080"
				CONTACTS_API_ADDR:     "contacts.\(Backend.Namespace).svc:8080"
				USERSERVICE_API_ADDR:  "userservice.\(Backend.Namespace).svc:8080"
			}
		}

		ConfigMap: "demo-data-config": k8s.#ConfigMap & {
			apiVersion: "v1"
			kind:       "ConfigMap"
			metadata: name: "demo-data-config"
			data: {
				USE_DEMO_DATA:       "True"
				DEMO_LOGIN_USERNAME: "testuser"
				// All demo user accounts are hardcoded to use the login password 'bankofanthos'
				DEMO_LOGIN_PASSWORD: "bankofanthos"
			}
		}
	}

	CommonLabels: {
		"\(#Organization.Domain)/owner.name":       Tags.owner
		"\(#Organization.Domain)/environment.name": Tags.environment
		"\(#Organization.Domain)/tier.name":        Tags.tier

		// These are the common labels from upstream
		application: BankName
		environment: Tags.environment
		team:        Tags.owner
		tier:        Tags.tier
	}

	// Expose a way to get the bank frontend hostname, unified with the HTTPRoute.
	Hostname: HTTPRoutes["\(Tags.host_prefix)bank"].spec.hostnames[0]
}

// CommonLabels
#ComponentConfig: CommonLabels: _Stack.CommonLabels
