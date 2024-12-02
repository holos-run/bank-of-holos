package holos

Projects: #Projects & {
	network: #ProjectBuilder & {
		_components: {
			"gateway-api": _
		}
	}

	security: #ProjectBuilder & {
		team: "security"
		namespaces: "external-secrets": _
		namespaces: "cert-manager":     _
		_components: {
			"external-secrets-crds": _
			"external-secrets":      _
			"cert-manager":          _
			"local-ca":              _
		}
	}
}
