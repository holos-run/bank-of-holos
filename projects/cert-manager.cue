package holos

// Platform wide configuration
#CertManager: {
	Version:   "1.15.3"
	Namespace: "cert-manager"
}

// Register the namespace
#Namespaces: (#CertManager.Namespace): _
