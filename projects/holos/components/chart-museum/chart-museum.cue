package holos

import rg "gateway.networking.k8s.io/referencegrant/v1beta1"

holos: Component.BuildPlan

Component: #Kubernetes & {
	Resources: [_]: [_]: metadata: namespace: "holos"

	Resources: {
		Deployment: chartmuseum: {
			metadata: name: "chartmuseum"
			spec: {
				replicas: 1
				selector: matchLabels: app: "chartmuseum"
				template: {
					metadata: labels: selector.matchLabels
					spec: {
						containers: [{
							name:  "chartmuseum"
							image: "ghcr.io/helm/chartmuseum:v0.15.0"
							ports: [{name: "http", containerPort: 80}]
							envFrom: [{secretRef: name: ExternalSecret.auth.metadata.name}]
							env: [
								{name: "PORT", value: "80"},
								{name: "STORAGE", value: "local"},
								{name: "STORAGE_LOCAL_ROOTDIR", value: "/charts"},
							]
							volumeMounts: [{name: "charts", mountPath: "/charts"}]
							readinessProbe: {
								httpGet: {
									path: "/health"
									port: "http"
								}
								initialDelaySeconds: 5
								periodSeconds:       10
							}
						}]
						volumes: [{
							name: "charts"
							emptyDir: {}
						}]
					}
				}
			}
		}

		Service: chartmuseum: {
			metadata: name: "chartmuseum"
			spec: {
				ports: [{
					port:       80
					targetPort: "http"
					protocol:   "TCP"
					name:       "http"
				}]
				selector: Deployment.chartmuseum.spec.selector.matchLabels
			}
		}

		ExternalSecret: auth: {
			metadata: name: "chartmuseum-auth"
			spec: {
				refreshInterval: "24h"
				target: {
					creationPolicy: "Owner"
					deletionPolicy: "Delete"
					template: {
						type:          "Opaque"
						mergePolicy:   "Merge"
						engineVersion: "v2"
						data: BASIC_AUTH_USER: "admin"
						data: BASIC_AUTH_PASS: "{{ .password }}"
					}
				}
				dataFrom: [
					{
						// Specify the top level key for the generated value.  This key is
						// used in the ExternalSecret.spec.target.template.data templates.
						rewrite: [{transform: template: "password"}]
						sourceRef: {
							generatorRef: {
								apiVersion: "generators.external-secrets.io/v1alpha1"
								kind:       "Password"
								name:       Password.admin.metadata.name
							}
						}
					},
				]
			}
		}

		Password: admin: {
			metadata: name: "admin-password-generator"
			spec: {
				length:      32
				digits:      4
				symbols:     0
				allowRepeat: true
				noUpper:     false
			}
		}

		// Grant the Gateway namespace the ability to refer to the backend service
		// from HTTPRoute resources.
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
	}
}
