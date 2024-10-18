// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f deploy/clusters/aws1/components/gateway-api/gateway-api.gen.yaml

package v1beta1

import "strings"

// GatewayClass describes a class of Gateways available to the
// user for creating
// Gateway resources.
//
//
// It is recommended that this resource be used as a template for
// Gateways. This
// means that a Gateway is based on the state of the GatewayClass
// at the time it
// was created and changes to the GatewayClass or associated
// parameters are not
// propagated down to existing Gateways. This recommendation is
// intended to
// limit the blast radius of changes to GatewayClass or associated
// parameters.
// If implementations choose to propagate GatewayClass changes to
// existing
// Gateways, that MUST be clearly documented by the
// implementation.
//
//
// Whenever one or more Gateways are using a GatewayClass,
// implementations SHOULD
// add the `gateway-exists-finalizer.gateway.networking.k8s.io`
// finalizer on the
// associated GatewayClass. This ensures that a GatewayClass
// associated with a
// Gateway is not deleted while in use.
//
//
// GatewayClass is a Cluster level resource.
#GatewayClass: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "gateway.networking.k8s.io/v1beta1"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "GatewayClass"
	metadata!: {
		name!: strings.MaxRunes(253) & strings.MinRunes(1) & {
			string
		}
		namespace?: strings.MaxRunes(63) & strings.MinRunes(1) & {
			string
		}
		labels?: {
			[string]: string
		}
		annotations?: {
			[string]: string
		}
	}

	// Spec defines the desired state of GatewayClass.
	spec!: #GatewayClassSpec
}

// Spec defines the desired state of GatewayClass.
#GatewayClassSpec: {
	// ControllerName is the name of the controller that is managing
	// Gateways of
	// this class. The value of this field MUST be a domain prefixed
	// path.
	//
	//
	// Example: "example.net/gateway-controller".
	//
	//
	// This field is not mutable and cannot be empty.
	//
	//
	// Support: Core
	controllerName: strings.MaxRunes(253) & strings.MinRunes(1) & {
		=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*\\/[A-Za-z0-9\\/\\-._~%!$&'()*+,;=:]+$"
	}

	// Description helps describe a GatewayClass with more details.
	description?: strings.MaxRunes(64)

	// ParametersRef is a reference to a resource that contains the
	// configuration
	// parameters corresponding to the GatewayClass. This is optional
	// if the
	// controller does not require any additional configuration.
	//
	//
	// ParametersRef can reference a standard Kubernetes resource,
	// i.e. ConfigMap,
	// or an implementation-specific custom resource. The resource can
	// be
	// cluster-scoped or namespace-scoped.
	//
	//
	// If the referent cannot be found, the GatewayClass's
	// "InvalidParameters"
	// status condition will be true.
	//
	//
	// A Gateway for this GatewayClass may provide its own
	// `parametersRef`. When both are specified,
	// the merging behavior is implementation specific.
	// It is generally recommended that GatewayClass provides defaults
	// that can be overridden by a Gateway.
	//
	//
	// Support: Implementation-specific
	parametersRef?: {
		// Group is the group of the referent.
		group: strings.MaxRunes(253) & {
			=~"^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"
		}

		// Kind is kind of the referent.
		kind: strings.MaxRunes(63) & strings.MinRunes(1) & {
			=~"^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$"
		}

		// Name is the name of the referent.
		name: strings.MaxRunes(253) & strings.MinRunes(1)

		// Namespace is the namespace of the referent.
		// This field is required when referring to a Namespace-scoped
		// resource and
		// MUST be unset when referring to a Cluster-scoped resource.
		namespace?: strings.MaxRunes(63) & strings.MinRunes(1) & {
			=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
		}
	}
}