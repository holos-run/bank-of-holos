package holos

// #NamedObjects represents a collection of objects useful primarily to get a
// handle on the name of some resource.
#NamedObjects: [NAME=string]: {
	metadata: name: NAME
	metadata: labels?: [string]:      string
	metadata: annotations?: [string]: string
}
