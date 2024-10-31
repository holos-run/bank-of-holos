package holos

#CertManager: {
	Version:   string
	Namespace: string
}

// Platform wide configuration
_CertManager: {
	Version:   "v1.16.1"
	Namespace: "cert-manager"
}

// Register the namespace
_Namespaces: (_CertManager.Namespace): _
