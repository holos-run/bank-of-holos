package holos

// Produce a helm chart build plan.
(#Helm & Chart).BuildPlan

let Chart = {
	Name:    "podinfo"
	Version: "6.6.2"
	Repo: name: "podinfo"
	Repo: url:  "https://stefanprodan.github.io/podinfo"
}
