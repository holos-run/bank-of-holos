@if(TestPrivateRepo)
package holos

// Test holos can access a private repository with basic auth.
// https://github.com/holos-run/holos/issues/370
Projects: holos: #ProjectBuilder & {
	team: "holos-authors"

	namespaces: holos:            _
	_components: "private-chart": _
}
