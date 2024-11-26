package holos

// Injected from Platform.spec.components.parameters.EnvironmentName
EnvironmentName: string @tag(EnvironmentName)

Environments: #Environments & {
	"prod-pdx1": {
		tier:         "prod"
		jurisdiction: "us"
		state:        "oregon"
	}
	"prod-pdx2": {
		tier:         "prod"
		jurisdiction: "us"
		state:        "oregon"
	}
	// Nonprod environments are colocated together.
	_nonprod: {
		tier:         "nonprod"
		jurisdiction: "us"
		state:        "oregon"
	}
	dev:   _nonprod
	test:  _nonprod
	stage: _nonprod
}
