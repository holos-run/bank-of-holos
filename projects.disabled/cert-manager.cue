package holos

#CertManager: {
	Version:   string
	Namespace: string
}

// Platform wide configuration
CertManager: #CertManager & {
	Version:   "v1.16.1"
	Namespace: "cert-manager"
}

// Register the namespace
Namespaces: (CertManager.Namespace): _
