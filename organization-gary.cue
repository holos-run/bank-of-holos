// NOTE: This IF is checking for a build tag that is passed to Holos via "-t gary"
@if(gary)
package holos

Organization: #Organization & {
	DisplayName: "Bank of Holos: Gary Edition"
	Domain:      "holos.localhost"
	RepoURL:     "https://github.com/glarizza/bank-of-holos.git"
}
