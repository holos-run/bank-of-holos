package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

let BankName = _Stack.BankName

_Kubernetes: #Kubernetes & {
	Namespace: _Stack.Backend.Namespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests
	Resources: {
		ExternalSecret: "ledger-db-config": {
			metadata: name: string
			spec: {
				target: name: metadata.name
				dataFrom: [{extract: {key: metadata.name}}]
				refreshInterval: "5s"
				secretStoreRef: kind: "SecretStore"
				secretStoreRef: name: _Stack.Resources.SecretStore[BankName].metadata.name
			}
		}

		Service: "ledger-db": {
			apiVersion: "v1"
			kind:       "Service"
			metadata: name: "ledger-db"
			spec: {
				ports: [{
					name:       "tcp"
					port:       5432
					targetPort: 5432
				}]
				selector: app: "ledger-db"
				type: "ClusterIP"
			}
		}

		StatefulSet: "ledger-db": {
			apiVersion: "apps/v1"
			kind:       "StatefulSet"
			metadata: name: "ledger-db"
			spec: {
				replicas: 1
				selector: matchLabels: app: "ledger-db"
				serviceName: "ledger-db"
				template: {
					metadata: labels: app: "ledger-db"
					spec: {
						containers: [{
							envFrom: [{
								configMapRef: name: "environment-config"
							}, {
								secretRef: name: "ledger-db-config"
							}, {
								secretRef: name: "demo-data-config"
							}]
							image: "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/ledger-db:v0.6.5@sha256:cc4fd25f301ab6d46b1312244d6931babc4c6cb66c5cb6d31d4a1adfa318a321"
							name:  "postgres"
							ports: [{containerPort: 5432}]
							resources: {
								limits: {
									cpu:    "250m"
									memory: "1Gi"
								}
								requests: {
									cpu:    "100m"
									memory: "512Mi"
								}
							}
							volumeMounts: [{
								mountPath: "/var/lib/postgresql/data"
								name:      "postgresdb"
								subPath:   "postgres"
							}]
						}]
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
