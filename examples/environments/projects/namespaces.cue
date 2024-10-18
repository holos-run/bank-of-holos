package holos

import corev1 "k8s.io/api/core/v1"

// #Namespaces defines all managed namespaces in the Platform.
// Holos adopts the sig-multicluster position of namespace sameness.
#Namespaces: {
	[Name=string]: corev1.#Namespace & {
		metadata: name: Name
	}
}

// Registration point for namespaces
_Namespaces: #Namespaces
