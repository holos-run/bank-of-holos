package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

let BankName = _BankOfHolos.Name

let CommonLabels = {
	application: BankName
	environment: "development"
	tier:        "backend"
}

_Kubernetes: #Kubernetes & {
	Name:      "bank-backend-config"
	Namespace: _BankOfHolos.Backend.Namespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace
	Resources: [_]: [_]: metadata: labels:    CommonLabels

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests/userservice.yaml
	Resources: {
		// Allow HTTPRoutes in the ingress gateway namespace to reference Services
		// in this namespace.
		ReferenceGrant: grant: _ReferenceGrant

		// Include shared resources
		_BankOfHolos.Resources
	}
}
