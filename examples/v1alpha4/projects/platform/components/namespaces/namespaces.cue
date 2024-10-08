package holos

let Env = _Tags.environment

_BuildPlan: {
	Name: "\(Env)-namespaces"
	Resources: Namespace: #Namespaces
}

// Some fake namespaces

#Namespaces: "\(Env)-jeff": _
#Namespaces: "\(Env)-gary": _
#Namespaces: "\(Env)-nate": _
