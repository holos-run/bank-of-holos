package holos

#Istio: {
	Version: string
	System: Namespace:  string
	Gateway: Namespace: string
	Values: {...}
}

// #Istio represents platform wide configuration
Istio: #Istio & {
	Version: "1.23.1"
	System: Namespace:  "istio-system"
	Gateway: Namespace: "istio-ingress"

	// Constrain Helm values for safer, easier upgrades and consistency across
	// platform components.
	Values: global: istioNamespace: System.Namespace
	// Configure ambient mode
	Values: profile: "ambient"
}

// Register the Namespaces
Namespaces: (Istio.System.Namespace): _
