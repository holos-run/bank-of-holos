package holos

let Project = _Stack.AppProjects["\(_Stack.Tags.prefix)bank-security"]

_Stack: AppProject:      Project
#ArgoConfig: AppProject: Project.metadata.name
