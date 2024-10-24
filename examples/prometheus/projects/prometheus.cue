package holos

#Prometheus: {
	// Types
	BlackboxServiceName: string
	BlackboxServicePort: number

	// Constraints
	BlackboxServiceName: =~"blackbox"
	BlackboxServicePort: >0
	BlackboxServicePort: <=65535
}

// Concrete values
_Prometheus: #Prometheus & {
	BlackboxServiceName: "blackbox"
	BlackboxServicePort: 80
}
