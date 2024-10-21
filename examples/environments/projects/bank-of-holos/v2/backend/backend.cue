package holos

let Project = _Stack.AppProjects["\(_Stack.Tags.prefix)bank-backend"]

_Stack: AppProject:      Project
#ArgoConfig: AppProject: Project.metadata.name
