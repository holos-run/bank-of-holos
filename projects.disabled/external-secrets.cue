package holos

// Platform wide configuration
#ExternalSecrets: {
	Version:   string
	Namespace: string
}

ExternalSecrets: #ExternalSecrets & {
	Version:   "0.10.3"
	Namespace: "external-secrets"
}

// Register the namespace
Namespaces: (ExternalSecrets.Namespace): _
