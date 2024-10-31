package holos

import rg "gateway.networking.k8s.io/referencegrant/v1beta1"

_ReferenceGrant: rg.#ReferenceGrant & {
	metadata: name:      _Istio.Gateway.Namespace
	metadata: namespace: string
	spec: from: [{
		group:     "gateway.networking.k8s.io"
		kind:      "HTTPRoute"
		namespace: _Istio.Gateway.Namespace
	}]
	spec: to: [{
		group: ""
		kind:  "Service"
	}]
}
