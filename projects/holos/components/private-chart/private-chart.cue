package holos

holos: Component.BuildPlan

// Test holos can access a private repository with basic auth.
// https://github.com/holos-run/holos/issues/370
Component: #Helm & {
	Chart: {
		name:    "mychart"
		version: "0.1.0"
		repository: {
			name: "holos-test"
			url:  "https://charts.holos.localhost"
			// auth: username: fromEnv:   "HOLOS_TEST_USER"
			auth: username: value:   "admin"
			auth: password: fromEnv: "HOLOS_TEST_PASS"
		}
	}
}
