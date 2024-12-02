package holos

import rg "gateway.networking.k8s.io/referencegrant/v1beta1"

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

let BankName = BankOfHolos.Name
let BackendNamespace = BankOfHolos.configuration.environments[EnvironmentName].backend.namespace

let CommonLabels = {
	application: BankName
	environment: EnvironmentName
	tier:        "backend"
}

Component: #Kubernetes & {
	Namespace: BackendNamespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace
	Resources: [_]: [_]: metadata: labels:    CommonLabels

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests/userservice.yaml
	Resources: {
		// Allow HTTPRoutes in the ingress gateway namespace to reference Services
		// in this namespace.
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
