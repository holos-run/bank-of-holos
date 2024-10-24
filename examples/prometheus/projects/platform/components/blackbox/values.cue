package holos

_Helm: Values: #Values & {
	fullnameOverride: _Prometheus.BlackboxServiceName
	service: port: _Prometheus.BlackboxServicePort
}
