@if(!NoKargo && !NoArgoRollouts && !NoArgoCD)
package holos

Component: Resources: {
	Warehouse: frontend: spec: {
		subscriptions: [{
			image: {
				repoURL:          "us-central1-docker.pkg.dev/bank-of-anthos-ci/bank-of-anthos/frontend"
				semverConstraint: "^v0.6.5"
				discoveryLimit:   5
			}
		}]
	}
}
