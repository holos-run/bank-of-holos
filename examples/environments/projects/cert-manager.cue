package holos

// Platform wide configuration
#CertManager: {
	Version:   "v1.16.1"
	Namespace: "cert-manager"
}

// Register the namespace
#Namespaces: (#CertManager.Namespace): _
