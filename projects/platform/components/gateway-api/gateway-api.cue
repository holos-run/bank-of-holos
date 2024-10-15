package holos

_Kustomization: {
	Name: "gateway-api"

	Files: {
		"standard/gateway.networking.k8s.io_gatewayclasses.yaml":  _
		"standard/gateway.networking.k8s.io_gateways.yaml":        _
		"standard/gateway.networking.k8s.io_grpcroutes.yaml":      _
		"standard/gateway.networking.k8s.io_httproutes.yaml":      _
		"standard/gateway.networking.k8s.io_referencegrants.yaml": _
	}
}

// Produce a kubectl kustomize build plan.
(#Kustomize & _Kustomization).BuildPlan
