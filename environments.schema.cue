package holos

#Environment: {
	name:         string
	tier:         string | "prod" | *"nonprod"
	jurisdiction: string | *"us" | "eu" | "uk" | "global"
	state:        string | *"oregon" | "ohio" | "germany" | "netherlands" | "england" | "global"

	// Prod environment names must be prefixed with prod for clarity.
	if tier == "prod" {
		name: "prod" | =~"^prod-"
	}
}

#Environments: {
	[NAME=string]: #Environment & {
		name: NAME
	}
}
