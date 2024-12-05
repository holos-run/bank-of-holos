package holos

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

let BankName = BankOfHolos.Name
let BackendNamespace = BankOfHolos.configuration.environments[EnvironmentName].backend.namespace

let CommonLabels = {
	application: BankName
	environment: EnvironmentName
	team:        "accounts"
	tier:        "db"
}

Component: #Kubernetes & {
	Namespace: BackendNamespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests/accounts-db.yaml
	Resources: {
		ConfigMap: "accounts-db-config": {
			apiVersion: "v1"
			data: {
				ACCOUNTS_DB_URI:   "postgresql://accounts-admin:accounts-pwd@accounts-db:5432/accounts-db"
				POSTGRES_DB:       "accounts-db"
				POSTGRES_PASSWORD: "accounts-pwd"
				POSTGRES_USER:     "accounts-admin"
			}
			kind: "ConfigMap"
			metadata: {
				labels: {
					app: "accounts-db"
					CommonLabels
				}
				name: "accounts-db-config"
			}
		}

		Service: "accounts-db": {
			apiVersion: "v1"
			kind:       "Service"
			metadata: {
				name:   "accounts-db"
				labels: CommonLabels
			}
			spec: {
				ports: [{
					name:       "tcp"
					port:       5432
					protocol:   "TCP"
					targetPort: 5432
				}]
				selector: {
					app: "accounts-db"
					CommonLabels
				}
				type: "ClusterIP"
			}
		}

		StatefulSet: "accounts-db": {
			apiVersion: "apps/v1"
			kind:       "StatefulSet"
			metadata: {
				name:   "accounts-db"
				labels: CommonLabels
			}
			spec: {
				replicas: 1
				selector: matchLabels: {
					app: "accounts-db"
					CommonLabels
				}
				serviceName: "accounts-db"
				template: {
					metadata: labels: {
						app: "accounts-db"
						CommonLabels
					}
					spec: {
						containers: [{
							envFrom: [{
								configMapRef: name: "environment-config"
							}, {
								configMapRef: name: "accounts-db-config"
							}, {
								configMapRef: name: "demo-data-config"
							}]
							image: "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/accounts-db:v0.6.5@sha256:abb955756a82b115e0fd9c5fa1527ae1a744b398b357fd6d7a26348feccad181"
							name:  "accounts-db"
							ports: [{containerPort: 5432}]
							resources: {
								limits: {
									cpu:    "250m"
									memory: "512Mi"
								}
								requests: {
									cpu:    "100m"
									memory: "128Mi"
								}
							}
							volumeMounts: [{
								mountPath: "/var/lib/postgresql/data"
								name:      "postgresdb"
								subPath:   "postgres"
							}]
						}]
						serviceAccount:     BankName
						serviceAccountName: BankName
						volumes: [{
							emptyDir: {}
							name: "postgresdb"
						}]
					}
				}
			}
		}
	}
}
