package holos

// Produce a Kustomize BuildPlan for Holos
_Kustomize.BuildPlan

// https://github.com/mccutchen/go-httpbin/blob/v2.15.0/kustomize/README.md
_Kustomize: #Kustomize & {
	KustomizeConfig: Resources: "github.com/mccutchen/go-httpbin/kustomize": _
	KustomizeConfig: Kustomization: commonLabels: "app.kubernetes.io/name": "httpbin"
}
