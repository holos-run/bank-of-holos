package holos

import rg "gateway.networking.k8s.io/referencegrant/v1beta1"

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

Component: #Kubernetes & {
	Namespace: BankOfHolos.configuration.environments[EnvironmentName].frontend.namespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests/frontend.yaml
	Resources: {
		Service: frontend: {
			metadata: name: "frontend"
			metadata: labels: {
				application: BankOfHolos.Name
				environment: EnvironmentName
				team:        "frontend"
				tier:        "web"
			}
			spec: {
				selector: {
					app:         "frontend"
					application: BankOfHolos.Name
					environment: EnvironmentName
					tier:        "web"
				}
				_ports: http: {
					name:       "http"
					port:       80
					targetPort: 8080
					protocol:   "TCP"
				}
				ports: [for x in _ports {x}]
			}
		}

		Deployment: frontend: {
			metadata: name: "frontend"
			metadata: labels: {
				application: BankOfHolos.Name
				environment: EnvironmentName
				team:        "frontend"
				tier:        "web"
			}
			spec: {
				selector: matchLabels: {
					app:         "frontend"
					application: BankOfHolos.Name
					environment: EnvironmentName
				}
				template: {
					metadata: labels: {
						app:         "frontend"
						application: BankOfHolos.Name
						environment: EnvironmentName
						team:        "frontend"
						tier:        "web"
					}
					spec: {
						securityContext: {
							seccompProfile: type: "RuntimeDefault"
							fsGroup:      1000
							runAsGroup:   1000
							runAsNonRoot: true
							runAsUser:    1000
						}
						serviceAccountName:            "bank-of-holos"
						terminationGracePeriodSeconds: 5
						containers: [{
							env: [{
								name:  "BANK_NAME"
								value: Organization.DisplayName
							}, {
								name:  "ENV_PLATFORM"
								value: "local"
							}, {
								name:  "VERSION"
								value: "v0.6.5"
							}, {
								name:  "PORT"
								value: "8080"
							}, {
								name:  "ENABLE_TRACING"
								value: "false"
							}, {
								name:  "SCHEME"
								value: "https"
							}, {
								name:  "LOG_LEVEL"
								value: "info"
							}, {
								name: "DEFAULT_USERNAME"
								valueFrom: configMapKeyRef: {
									key:  "DEMO_LOGIN_USERNAME"
									name: "demo-data-config"
								}
							}, {
								name: "DEFAULT_PASSWORD"
								valueFrom: configMapKeyRef: {
									key:  "DEMO_LOGIN_PASSWORD"
									name: "demo-data-config"
								}
							}, {
								name: "REGISTERED_OAUTH_CLIENT_ID"
								valueFrom: configMapKeyRef: {
									key:      "DEMO_OAUTH_CLIENT_ID"
									name:     "oauth-config"
									optional: true
								}
							}, {
								name: "ALLOWED_OAUTH_REDIRECT_URI"
								valueFrom: configMapKeyRef: {
									key:      "DEMO_OAUTH_REDIRECT_URI"
									name:     "oauth-config"
									optional: true
								}
							}]
							envFrom: [{
								configMapRef: name: "environment-config"
							}, {
								configMapRef: name: "service-api-config"
							}]
							image: "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/frontend:v0.6.5@sha256:d72050f70d12383e4434ad04d189b681dc625f696087ddf0b5df641645c9dafa"
							livenessProbe: {
								httpGet: {
									path: "/ready"
									port: 8080
								}
								initialDelaySeconds: 60
								periodSeconds:       15
								timeoutSeconds:      30
							}
							name: "front"
							readinessProbe: {
								httpGet: {
									path: "/ready"
									port: 8080
								}
								initialDelaySeconds: 10
								periodSeconds:       5
								timeoutSeconds:      10
							}
							resources: {
								limits: {
									cpu:    "250m"
									memory: "128Mi"
								}
								requests: {
									cpu:    "100m"
									memory: "64Mi"
								}
							}
							securityContext: {
								allowPrivilegeEscalation: false
								capabilities: drop: ["all"]
								privileged:             false
								readOnlyRootFilesystem: true
							}
							volumeMounts: [{
								mountPath: "/tmp"
								name:      "tmp"
							}, {
								mountPath: "/tmp/.ssh"
								name:      "publickey"
								readOnly:  true
							}]
						}]
						volumes: [
							{
								emptyDir: {}
								name: "tmp"
							},
							{
								name: "publickey"
								secret: {
									items: [{key: "jwtRS256.key.pub", path: "publickey"}]
									secretName: "jwt-key"
								}
							},
						]
					}
				}
			}
		}

		ReferenceGrant: "istio-ingress": rg.#ReferenceGrant & {
			metadata: name: "istio-ingress"
			spec: from: [{
				group:     "gateway.networking.k8s.io"
				kind:      "HTTPRoute"
				namespace: "istio-ingress"
			}]
			spec: to: [{
				group: ""
				kind:  "Service"
			}]
		}

		// Include shared resources
		_Bank.Resources
	}
}
