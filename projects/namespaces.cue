package holos

import corev1 "k8s.io/api/core/v1"

// #Namespaces defines the structure holding all managed namespaces in the
// Platform.  Holos adopts the sig-multicluster position of namespace sameness.
#Namespaces: {
	[Name=string]: corev1.#Namespace & {
		metadata: name: Name
	}
}

// Namespaces represents all managed namespaces across the platform.  Mix
// namespaces into this structure to manage them automatically from the
// namespaces component.
Namespaces: #Namespaces
