package holos

// Produce a kubernetes objects build plan.
_Kubernetes.BuildPlan

let CommonLabels = {
	application: _Stack.BankName
	environment: _Stack.Tags.environment
	tier:        "backend"
}

_Kubernetes: #Kubernetes & {
	Namespace: _Stack.Backend.Namespace

	// Ensure resources go in the correct namespace
	Resources: [_]: [_]: metadata: namespace: Namespace
	Resources: [_]: [_]: metadata: labels:    CommonLabels

	// https://github.com/GoogleCloudPlatform/bank-of-anthos/blob/release/v0.6.5/kubernetes-manifests/userservice.yaml
	Resources: {
		// Allow HTTPRoutes in the ingress gateway namespace to reference Services
		// in this namespace.
		ReferenceGrant: grant: #ReferenceGrant & {
			metadata: namespace: Namespace
		}

		// Include shared resources
		_Stack.Resources
	}
}
