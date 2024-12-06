@if(ChartMuseum)
package holos

Projects: holos: #ProjectBuilder & {
	team: "holos-authors"

	namespaces: holos:           _
	_components: "chart-museum": _
}
// Register the HTTPRoute to the backend Service
HTTPRoutes: charts: _backendRefs: chartmuseum: namespace: "holos"
