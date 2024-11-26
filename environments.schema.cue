package holos

#Environment: {
	name:         string
	tier:         "prod" | "nonprod"
	jurisdiction: "us" | "eu" | "uk" | "global"
	state:        "oregon" | "ohio" | "germany" | "netherlands" | "england" | "global"

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
