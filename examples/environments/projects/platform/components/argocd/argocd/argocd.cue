package holos

import "strings"

// Produce a helm chart build plan.
_Helm.BuildPlan

_Helm: #Helm & {
	Namespace: _ArgoCD.Namespace

	Chart: {
		name:    "argo-cd"
		release: "argocd"
		version: _ArgoCD.ChartVersion
		repository: {
			name: "argocd"
			url:  "https://argoproj.github.io/argo-helm"
		}
	}
	EnableHooks: true

	// Grant the Gateway namespace the ability to refer to the backend service
	// from HTTPRoute resources.
	Resources: ReferenceGrant: (#Istio.Gateway.Namespace): #ReferenceGrant & {
		metadata: namespace: Namespace
	}

	Values: #Values & {
		kubeVersionOverride: "1.29.0"
		// handled in the argo-crds component
		crds: install: false
		// Configure the same fqdn the HTTPRoute is configured with.
		global: domain: _HTTPRoutes.argocd.spec.hostnames[0]
		dex: enabled:   false
		// the platform handles mutual tls to the backend
		configs: params: "server.insecure": true

		configs: cm: {
			"admin.enabled":           false
			"oidc.config":             "{}"
			"users.anonymous.enabled": "true"
		}

		// Refer to https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/
		let Policy = [
			"g, argocd-view, role:readonly",
			"g, prod-cluster-view, role:readonly",
			"g, prod-cluster-edit, role:readonly",
			"g, prod-cluster-admin, role:admin",
		]

		configs: rbac: "policy.csv":     strings.Join(Policy, "\n")
		configs: rbac: "policy.default": "role:admin"
	}
}
