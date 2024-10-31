package holos

// Platform wide configuration
#ExternalSecrets: {
	Version:   string
	Namespace: string
}

_ExternalSecrets: #ExternalSecrets & {
	Version:   "0.10.3"
	Namespace: "external-secrets"
}

// Register the namespace
_Namespaces: (_ExternalSecrets.Namespace): _
