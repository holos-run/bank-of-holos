// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/holos-run/holos/api/core/v1alpha3

package v1alpha3

// KustomizeBuild represents a [Component] that renders plain yaml files in
// the holos component directory using `kubectl kustomize build`.
#KustomizeBuild: {
	#Component
	kind: string & "KustomizeBuild" @go(Kind)
}