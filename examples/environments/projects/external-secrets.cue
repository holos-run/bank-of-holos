package holos

// Platform wide configuration
#ExternalSecrets: {
	Version:   "0.10.3"
	Namespace: "external-secrets"
}

// Register the namespace
#Namespaces: (#ExternalSecrets.Namespace): _
