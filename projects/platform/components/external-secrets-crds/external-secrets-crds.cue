package holos

_Kustomization: {
	Name: "external-secrets-crds"

	Kustomization: {
		resources: ["https://raw.githubusercontent.com/external-secrets/external-secrets/v\(#ExternalSecrets.Version)/deploy/crds/bundle.yaml"]
	}
}

(#Kustomize & _Kustomization).BuildPlan
