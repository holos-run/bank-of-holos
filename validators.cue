@if(validate)
package holos

// Configure all component kinds to validate against the policy directory.
#ComponentConfig: Validators: cue: {
	kind: "Command"
	// Note --path maps each resource to a top level field named by the kind.
	command: args: [
		"holos",
		"cue",
		"vet",
		"./policy",
		"--path=strings.ToLower(kind)",
		"--path=metadata.name",
	]
}
