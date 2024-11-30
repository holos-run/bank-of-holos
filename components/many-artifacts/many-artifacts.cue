package holos

let SEQ = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

_Artifacts: {
	[NAME=string]: {
		artifact: "components/\(Component.Name)/\(NAME).gen.yaml"
		generators: [
			for x in SEQ {
				{
					kind:   "Resources"
					output: "\(NAME)\(x).gen.yaml"
					resources: #Resources & {
						Namespace: "\(NAME)\(x)": _
					}
				}
			},
		]
		transformers: [
			{
				kind: "Kustomize"
				inputs: [for x in generators {x.output}]
				output: "a-\(artifact)"
				kustomize: kustomization: {
					apiVersion: "kustomize.config.k8s.io/v1beta1"
					kind:       "Kustomization"
					resources:  inputs
				}
			},
			{
				kind: "Kustomize"
				inputs: [transformers[0].output]
				output: "b-\(artifact)"
				kustomize: kustomization: {
					apiVersion: "kustomize.config.k8s.io/v1beta1"
					kind:       "Kustomization"
					resources:  inputs
				}
			},
			{
				kind: "Kustomize"
				inputs: [transformers[1].output]
				output: "c-\(artifact)"
				kustomize: kustomization: {
					apiVersion: "kustomize.config.k8s.io/v1beta1"
					kind:       "Kustomization"
					resources:  inputs
				}
			},
			{
				kind: "Kustomize"
				inputs: [transformers[2].output]
				output: artifact
				kustomize: kustomization: {
					apiVersion: "kustomize.config.k8s.io/v1beta1"
					kind:       "Kustomization"
					resources:  inputs
				}
			},
		]
		validators: [{
			kind: "Command"
			inputs: [artifact]
			command: args: ["holos", "cue", "vet", "./policy", "--path=strings.ToLower(kind)", "--path=metadata.name"]
		}]
	}

	for x in SEQ {
		"foo\(x)": _
	}
}

holos: Component.BuildPlan

Component: #Kustomize & {
	Resources: Namespace: garbage: _
	for k, v in _Artifacts {
		Artifacts: (k): v
	}
}
