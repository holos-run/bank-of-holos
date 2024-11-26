package policy

import apps "k8s.io/api/apps/v1"

// Block Secret resources. kind will not unify with "Secret"
secret: kind: "Use an ExternalSecret instead.  Forbidden by security policy."

// Validate Deployment against Kubernetes type definitions.
deployment: apps.#Deployment
