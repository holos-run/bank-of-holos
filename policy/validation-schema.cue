package policy

import (
	core "k8s.io/api/core/v1"
	apps "k8s.io/api/apps/v1"
)

// Block Secret resources. kind will not unify with "Secret"
secret: [NAME=string]: kind: "Use an ExternalSecret instead.  Forbidden by security policy."

// Validate against Kubernetes type definitions.
namespace: [_]:  core.#Namespace
deployment: [_]: apps.#Deployment
