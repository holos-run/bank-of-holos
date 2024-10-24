package holos

import "encoding/yaml"

// Produce a Kustomize BuildPlan for Holos
_Kustomize.BuildPlan

// https://github.com/mccutchen/go-httpbin/blob/v2.15.0/kustomize/README.md
_Kustomize: #Kustomize & {
	KustomizeConfig: Resources: "github.com/mccutchen/go-httpbin/kustomize": _
	KustomizeConfig: Kustomization: {
		commonLabels: "app.kubernetes.io/name": "httpbin"
		_patches: probe: {
			target: kind: "Service"
			target: name: "httpbin"
			patch: yaml.Marshal([{
				op:    "add"
				path:  "/metadata/annotations/prometheus.io~1probe"
				value: "true"
			}])
		}
		patches: [for x in _patches {x}]
	}
}
