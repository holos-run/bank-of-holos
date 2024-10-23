// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/holos-run/holos/api/core/v1alpha2

package v1alpha2

// FilePath represents a file path.
#FilePath: string

// FileContent represents file contents.
#FileContent: string

// FileContentMap represents a mapping of file paths to file contents.  Paths
// are relative to the `holos` output "deploy" directory, and may contain
// sub-directories.
#FileContentMap: {[string]: #FileContent}

// BuildPlan represents a build plan for the holos cli to execute.  The purpose
// of a BuildPlan is to define one or more [HolosComponent] kinds.  For example a
// [HelmChart], [KustomizeBuild], or [KubernetesObjects].
//
// A BuildPlan usually has an additional empty [KubernetesObjects] for the
// purpose of using the [HolosComponent] DeployFiles field to deploy an ArgoCD
// or Flux gitops resource for the holos component.
#BuildPlan: {
	kind:       string & "BuildPlan"            @go(Kind)
	apiVersion: string & (string | *"v1alpha2") @go(APIVersion)
	spec:       #BuildPlanSpec                  @go(Spec)
}

// BuildPlanSpec represents the specification of the build plan.
#BuildPlanSpec: {
	// Disabled causes the holos cli to take no action over the [BuildPlan].
	disabled?: bool @go(Disabled)

	// Components represents multiple [HolosComponent] kinds to manage.
	components?: #BuildPlanComponents @go(Components)
}

#BuildPlanComponents: {
	resources?: {[string]: #KubernetesObjects} @go(Resources,map[Label]KubernetesObjects)
	kubernetesObjectsList?: [...#KubernetesObjects] @go(KubernetesObjectsList,[]KubernetesObjects)
	helmChartList?: [...#HelmChart] @go(HelmChartList,[]HelmChart)
	kustomizeBuildList?: [...#KustomizeBuild] @go(KustomizeBuildList,[]KustomizeBuild)
}

// HolosComponent defines the fields common to all holos component kinds.  Every
// holos component kind should embed HolosComponent.
#HolosComponent: {
	// Kind is a string value representing the resource this object represents.
	kind: string @go(Kind)

	// APIVersion represents the versioned schema of this representation of an object.
	apiVersion: string & (string | *"v1alpha2") @go(APIVersion)

	// Metadata represents data about the holos component such as the Name.
	metadata: #Metadata @go(Metadata)

	// APIObjectMap holds the marshalled representation of api objects.  Useful to
	// mix in resources to each HolosComponent type, for example adding an
	// ExternalSecret to a HelmChart HolosComponent.  Refer to [APIObjects].
	apiObjectMap?: #APIObjectMap @go(APIObjectMap)

	// DeployFiles represents file paths relative to the cluster deploy directory
	// with the value representing the file content.  Intended for defining the
	// ArgoCD Application resource or Flux Kustomization resource from within CUE,
	// but may be used to render any file related to the build plan from CUE.
	deployFiles?: #FileContentMap @go(DeployFiles)

	// Kustomize represents a kubectl kustomize build post-processing step.
	kustomize?: #Kustomize @go(Kustomize)

	// Skip causes holos to take no action regarding this component.
	skip: bool & (bool | *false) @go(Skip)
}

// Metadata represents data about the holos component such as the Name.
#Metadata: {
	// Name represents the name of the holos component.
	name: string @go(Name)

	// Namespace is the primary namespace of the holos component.  A holos
	// component may manage resources in multiple namespaces, in this case
	// consider setting the component namespace to default.
	//
	// This field is optional because not all resources require a namespace,
	// particularly CRD's and DeployFiles functionality.
	// +optional
	namespace?: string @go(Namespace)
}

// Kustomize represents resources necessary to execute a kustomize build.
// Intended for at least two use cases:
//
//  1. Process a [KustomizeBuild] [HolosComponent] which represents raw yaml
//     file resources in a holos component directory.
//  2. Post process a [HelmChart] [HolosComponent] to inject istio, patch jobs,
//     add custom labels, etc...
#Kustomize: {
	// KustomizeFiles holds file contents for kustomize, e.g. patch files.
	kustomizeFiles?: #FileContentMap @go(KustomizeFiles)

	// ResourcesFile is the file name used for api objects in kustomization.yaml
	resourcesFile?: string @go(ResourcesFile)
}
