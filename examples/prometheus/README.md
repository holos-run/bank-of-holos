# Prometheus Demo

Rewind to when we were just getting started with Kubernetes.  Let's try to:

1. Install Prometheus.
2. Probe httpbin to make sure the service is up.

The goal is to learn how prometheus probes a simple service to monitor uptime.

## Install Prometheus

Straight forward with helm following [install
chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus#install-chart).

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```
helm install prometheus prometheus-community/prometheus
```

Check it out

```
kubectl -n default port-forward svc/prometheus-server 8081:80
```

Great, we have prometheus, let's install httpbin and scrape it.

## Install httpbin

Instructions
[here](https://github.com/mccutchen/go-httpbin/tree/main?tab=readme-ov-file#kubernetes).

This project uses Kustomize instead of Helm.

No problem, still straight forward and easy to get going.

```
kubectl apply -k github.com/mccutchen/go-httpbin/kustomize
```

```
# Warning: 'commonLabels' is deprecated. Please use 'labels' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
service/httpbin created
deployment.apps/httpbin created
```

## Probe httpbin with prometheus

OK, so now we need to probe httpbin from prometheus.  Maybe it happens
automatically?

Let's bring up the prometheus web interface.

```
kubectl -n default port-forward svc/prometheus-server 8081:80
```

Hrm... http://localhost:8081/targets?search=httpbin comes up empty.

The helm chart configures prometheus to automatically probe services by default
in
[values.yaml](https://github.com/prometheus-community/helm-charts/blob/prometheus-25.27.0/charts/prometheus/values.yaml#L1059-L1060).

We need to annotate the Service with `prometheus.io/probe: "true"` for this to work.

Let's add the annotation.

```
kubectl kustomize github.com/mccutchen/go-httpbin/kustomize > httpbin.yaml
git add httpbin.yaml
code httpbin.yaml
```

Then make it look like this:

```diff
diff --git a/examples/prometheus/httpbin.yaml b/examples/prometheus/httpbin.yaml
index 51b3487..b53e683 100644
--- a/examples/prometheus/httpbin.yaml
+++ b/examples/prometheus/httpbin.yaml
@@ -4,6 +4,8 @@ metadata:
   labels:
     app.kubernetes.io/name: httpbin
   name: httpbin
+  annotations:
+    prometheus.io/probe: "true"
 spec:
   ports:
   - appProtocol: http
```

Apply it

```
kubectl apply -f httpbin.yaml
```

```
service/httpbin configured
deployment.apps/httpbin unchanged
```

Now http://localhost:8081/targets?search=httpbin has `kubernetes-services (0/1 up)`

And we see the error:

```
Get "http://blackbox:80/probe?module=http_2xx&target=httpbin.default.svc%3A80":
dial tcp: lookup blackbox on 10.43.0.10:53: no such host
```

Hrm...  no such host "blackbox"

We need to install the blackbox exporter.  There's probably a chart for that.

```
❯ helm search repo prometheus-community | grep blackbox
prometheus-community/prometheus-blackbox-exporter       9.0.1           v0.25.0         Prometheus Blackbox Exporter
```

Cool, let's install it:

```bash
helm install prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter
```

```txt
NAME: prometheus-blackbox-exporter
LAST DEPLOYED: Wed Oct 23 15:49:20 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
See https://github.com/prometheus/blackbox_exporter/ for how to configure Prometheus and the Blackbox Exporter.

1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-blackbox-exporter,app.kubernetes.io/instance=prometheus-blackbox-exporter" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT

```

Hrm, that still didn't fix it...

The prometheus-blackbox-exporter chart creates a service named
`prometheus-blackbox-exporter`, not `blackbox` like the prometheus chart is
configured to use.

Let's try to override the full name.

```
helm upgrade --set nameOverride=blackbox prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter
```

```
Error: UPGRADE FAILED: cannot patch "prometheus-blackbox-exporter" with kind Deployment: Deployment.apps "prometheus-blackbox-exporter" is invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app.kubernetes.io/instance":"prometheus-blackbox-exporter", "app.kubernetes.io/name":"blackbox"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
```

Guess we need to uninstall and start over.

```
helm uninstall prometheus-blackbox-exporter
```

```
release "prometheus-blackbox-exporter" uninstalled
```

```
helm install --set fullnameOverride=blackbox prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter
```

```
NAME: prometheus-blackbox-exporter
LAST DEPLOYED: Wed Oct 23 16:00:49 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
See https://github.com/prometheus/blackbox_exporter/ for how to configure Prometheus and the Blackbox Exporter.

1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-blackbox-exporter,app.kubernetes.io/instance=prometheus-blackbox-exporter" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Hrm...  It still doesn't work.

We need to change the port of the Blackbox service to match what Prometheus expects.  Blackbox defaults to [port: 9115](https://github.com/prometheus-community/helm-charts/blob/prometheus-25.27.0/charts/prometheus-blackbox-exporter/values.yaml#L203).  We can reconfigure the port by setting service.port as an input value, seen [here](https://github.com/prometheus-community/helm-charts/blob/prometheus-25.27.0/charts/prometheus-blackbox-exporter/templates/service.yaml#L22).

Let's try it:

```bash
helm upgrade --set service.port=80 --set fullnameOverride=blackbox prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter
```

```
Release "prometheus-blackbox-exporter" has been upgraded. Happy Helming!
NAME: prometheus-blackbox-exporter
LAST DEPLOYED: Wed Oct 23 16:06:06 2024
NAMESPACE: default
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
See https://github.com/prometheus/blackbox_exporter/ for how to configure Prometheus and the Blackbox Exporter.

1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=blackbox,app.kubernetes.io/instance=prometheus-blackbox-exporter" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Cool, we finally have a `blackbox` service listening on port `80` which should resolve the error.

Awesome: http://localhost:8081/targets?search=httpbin

```
kubernetes-services (1/1 up)
http://blackbox/probe
module="http_2xx"target="httpbin.default.svc:80"
```

## The path we're on

Couple of problems with the path we're on.

1. We need to always set the service port and full name override values from now on.  If we forget, helm upgrade will break the integration.
2. We need to automate this somehow so we don't forget.  We could write a script, but now we have to maintain a script and make sure everyone runs it, including our CI workflows when we get far enough along the path to deploy this with CI.
3. We could go straight to GitOps, but that's a bit much this early in our journey.

What's the fundamental problem here?

The prometheus chart isn't _well integrated_ with the blackbox chart.  They're
configured with different values for the blackbox service endpoints.  They don't
agree with each other.

## Holos

Holos helps by taking a holistic view of the components that go into the
cluster.  Holos provides an integration layer where we can define the endpoint
once, with strong type checking, then feed the data to both the prometheus and
the blackbox charts.

Holos uses CUE to define the configuration once, then provides a workflow to
fully render manifests from that configuration.

Let's see how it looks with holos.

First, generate the structure we're going to work in.  Start with an empty
directory.

```
mkdir prometheus
cd prometheus
```

Then let's generate the CUE code we'll use to manage our platform, which is
really just two helm charts at this point, not much of a platform yet.

```
holos generate platform v1alpha4
```

A platform is just a collection of components.  A component is something you
manage, a helm chart, a kustomize base, a single Namespace resource defined in
CUE, etc...

Platforms are empty by default:

```
holos render platform ./platform
```
```
rendered platform in 259.792µs
```

When we run `holos render platform`, holos uses CUE to build a platform
specification which is really just a fancy way of saying a list of components to
manage.

```yaml
cue export --out=yaml ./platform
```

```yaml
kind: Platform
apiVersion: v1alpha4
metadata:
  name: default
spec:
  components: []
```

This yaml looks like a Kubernetes resource, but is not.  `holos` processes this
Platform resource when you run `holos render platform`.

Let's manage the same helm chart we installed for Prometheus.

```bash
mkdir -p projects/platform/components/prometheus
```

```bash
cat <<EOF >projects/platform/components/prometheus/prometheus.cue
package holos

// Produce a helm chart build plan.
_Helm.BuildPlan

_Helm: #Helm & {
        Chart: {
                name:    "prometheus"
                version: "25.27.0"
                repository: {
                        name: "prometheus-community"
                        url:  "https://prometheus-community.github.io/helm-charts"
                }
        }
}
EOF
```

We need to register this chart with the platform:

```
cat <<EOF >platform/prometheus.cue
package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
        for Cluster in Fleet.clusters {
                _Platform: Components: "\(Cluster.name):prometheus": {
                        name:      "prometheus"
                        component: "projects/platform/components/prometheus"
                        cluster:   Cluster.name
                }
        }
}
EOF
```

Now we can render the platform:

```
holos render platform ./platform
```

```
cached prometheus 25.27.0
rendered prometheus for cluster local in 1.877683333s
rendered platform in 1.877744333s
```

This command wrote a fully rendered manifest to the following file.

```
deploy/clusters/local/components/prometheus/prometheus.gen.yaml
```

This file contains the output of the `helm template` command.

Next, we'll add the blackbox component.

```bash
mkdir -p projects/platform/components/blackbox
```

```bash
cat <<EOF >projects/platform/components/blackbox/blackbox.cue
package holos

// Produce a helm chart build plan.
_Helm.BuildPlan

_Helm: #Helm & {
	Chart: {
		name:    "prometheus-blackbox-exporter"
		version: "9.0.1"
		repository: {
			name: "prometheus-community"
			url:  "https://prometheus-community.github.io/helm-charts"
		}
	}
}
EOF
```

Basically the same as before except for the chart name and version fields.

We need to register the blackbox component like we did prometheus:

```bash
cat <<EOF >platform/blackbox.cue
package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):blackbox": {
			name:      "blackbox"
			component: "projects/platform/components/blackbox"
			cluster:   Cluster.name
		}
	}
}
EOF
```

Same as before, just `blackbox` instead of `prometheus` this time.

Now we have both when we render the platform:

```bash
holos render platform ./platform
```

```txt
rendered prometheus for cluster local in 244.35525ms
cached prometheus-blackbox-exporter 9.0.1
rendered blackbox for cluster local in 1.332973875s
rendered platform in 1.333053333s
```

Now we have two fully rendered manifests:

```bash
tree deploy 
```
```txt
deploy
└── clusters
    └── local
        └── components
            ├── blackbox
            │   └── blackbox.gen.yaml
            └── prometheus
                └── prometheus.gen.yaml

6 directories, 2 files
```

Let's add and commit this, then we need to get them to agree on the service
endpoint.

```bash
git add .
git commit -m 'add prometheus and blackbox'
```

## CUE

First, we define a structure both prometheus and blackbox derive their
configuration from.  We start to see how CUE helps with strong typing checking
and goes further with constraints.

With CUE and Holos, we need to think about the structure up-front, which can be
a bit more of an investment, but the pay off in reliability and safety down the
road is worth it.

```bash
cat <<EOF > projects/prometheus.cue
package holos

#Prometheus: {
	// Types
	BlackboxServiceName: string
	BlackboxServicePort: number

	// Constraints
	BlackboxServiceName: =~"blackbox"
	BlackboxServicePort: >0
	BlackboxServicePort: <=65535
}

// Concrete values
_Prometheus: #Prometheus & {
	BlackboxServiceName: "blackbox"
	BlackboxServicePort: 80
}
EOF
```

Now let's feed these two values to the blackbox chart like we did previously.

Holos and CUE allow us to type check all the input values.

Let's import the chart's values.yaml file into CUE

```bash
cue import -p holos -o- -l '#Values:' projects/platform/components/blackbox/vendor/9.0.1/prometheus-blackbox-exporter/values.yaml > projects/platform/components/blackbox/values.schema.cue
```

Set the name and port:

```bash
cat <<EOF > projects/platform/components/blackbox/values.cue
package holos

_Helm: Values: #Values & {
	fullnameOverride: _Prometheus.BlackboxServiceName
	service: port: _Prometheus.BlackboxServicePort
}
EOF
```

Let's render the platform:

```bash
holos render platform ./platform
```

```txt
could not run: could not marshal json projects/platform/components/blackbox: cue: marshal error: _Helm.Values.service.port: conflicting values 80 and 9115 at internal/builder/builder.go:63
_Helm.Values.service.port: conflicting values 80 and 9115:
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/values.cue:3:16
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/values.cue:5:17
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/values.schema.cue:195:9
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/prometheus.cue:17:23
could not run: could not render component: exit status 1 at builder/v1alpha4/builder.go:95
```

Notice the error: `conflicting values 80 and 9115`.  When we imported the default values.yaml file, CUE imported the default values as concrete values which cannot be changed.

We need to modify `values.schema.cue` to make 9115 the default value instead.

We do this by changing `9115` to `number | *9115` in CUE.  The asterisk
indicates a default value.

```diff
diff --git a/examples/prometheus/projects/platform/components/blackbox/values.schema.cue b/examples/prometheus/projects/platform/components/blackbox/values.schema.cue
index 8a603f8..51a5ab3 100644
--- a/examples/prometheus/projects/platform/components/blackbox/values.schema.cue
+++ b/examples/prometheus/projects/platform/components/blackbox/values.schema.cue
@@ -192,7 +192,7 @@ package holos
                annotations: {}
                labels: {}
                type: "ClusterIP"
-               port: 9115
+               port: number | *9115
                ipDualStack: {
                        enabled: false
                        ipFamilies: ["IPv6", "IPv4"]
```

Now we get a different error when we render:

```bash
holos render platform ./platform
```

```txt
could not run: could not marshal json projects/platform/components/blackbox: cue: marshal error: _Helm.Values.fullnameOverride: field not allowed at internal/builder/builder.go:63
_Helm.Values.fullnameOverride: field not allowed:
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/cue.mod/gen/github.com/holos-run/holos/api/author/v1alpha4/definitions_go_gen.cue:160:10
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/cue.mod/gen/github.com/holos-run/holos/api/core/v1alpha4/types_go_gen.cue:242:11
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/blackbox.cue:6:8
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/values.cue:3:16
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/values.cue:4:2
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/projects/platform/components/blackbox/values.schema.cue:3:10
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/schema.cue:51:14
    /Users/jeff/Holos/bank-of-holos/examples/prometheus/schema.cue:53:2
could not run: could not render component: exit status 1 at builder/v1alpha4/builder.go:95
```

That's strange...  `fullnameOverride` should be allowed, it worked when we ran the `helm install --set fullnameOverride=blackbox` command.

The helm chart authors forgot to include this value in the default `values.yaml`
file.  Holos and CUE make this easy to fix, we just need to add the field and define it as a string with a default value of `""`.

This matches the behavior of helm create when creating a new chart.

```bash
helm create foo; grep fullnameOverride foo/values.yaml; rm -rf foo
```

```
Creating foo
fullnameOverride: ""
```

We can add the missing field to a new file so if we import the chart again it
won't get written over.

```bash
cat <<EOF >projects/platform/components/blackbox/values.fixes.cue
package holos

// Define the fullnameOverride field, missing in the upstream values.yaml file.
#Values: fullnameOverride: string | *""
EOF
```

Now we're good to go:

```bash
holos render platform ./platform
```

```txt
rendered blackbox for cluster local in 198.379084ms
rendered prometheus for cluster local in 218.384916ms
rendered platform in 218.444959ms
```

Let's take a look at the fully rendered service in
`deploy/clusters/local/components/blackbox/blackbox.gen.yaml` and see if it's
named `blackbox` listening on port `80`.

Looks good:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/instance: prometheus-blackbox-exporter
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: prometheus-blackbox-exporter
    app.kubernetes.io/version: v0.25.0
    argocd.argoproj.io/instance: blackbox
    helm.sh/chart: prometheus-blackbox-exporter-9.0.1
    holos.run/component.name: blackbox
  name: blackbox
  namespace: default
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: http
  selector:
    app.kubernetes.io/instance: prometheus-blackbox-exporter
    app.kubernetes.io/name: prometheus-blackbox-exporter
    argocd.argoproj.io/instance: blackbox
    holos.run/component.name: blackbox
  type: ClusterIP
```

We could stop here, but we'd leave a pitfall for the next person to come along this path.  If the prometheus chart changes the default configuration from `blackbox:80` to something else then the integration will break.

Holos and CUE allow us to keep the two charts in lock step with the same value.
Let's configure the prometheus chart like we configured the blackbox chart.

First, import the values.yaml into CUE.

```
cue import -p holos -o- -l '#Values:' projects/platform/components/prometheus/vendor/25.27.0/prometheus/values.yaml > projects/platform/components/prometheus/va
lues.schema.cue
```

We'll modify the prometheus values directly to use the same values we provided
to the blackbox chart.

```diff
diff --git a/examples/prometheus/projects/platform/components/prometheus/values.schema.cue b/examples/prometheus/projects/platform/components/prometheus/values.schema.cue
index 9cb8c9f..41fbe2a 100644
--- a/examples/prometheus/projects/platform/components/prometheus/values.schema.cue
+++ b/examples/prometheus/projects/platform/components/prometheus/values.schema.cue
@@ -1083,7 +1083,7 @@ package holos
                                        target_label: "__param_target"
                                }, {
                                        target_label: "__address__"
-                                       replacement:  "blackbox"
+                                       replacement:  "\(_Prometheus.BlackboxServiceName):\(_Prometheus.BlackboxServicePort)"
                                }, {
                                        source_labels: ["__param_target"]
                                        target_label: "instance"
```

Second, have holos inject the values into helm.

```bash
cat <<EOF >projects/platform/components/prometheus/values.cue
package holos

_Helm: Values: #Values & {}
EOF
```

Now when we render the platform both charts are using the same value for the
blackbox endpoint.  We've integrated them together holistically.

```bash
holos render platform ./platform
```
```txt
rendered blackbox for cluster local in 175.419417ms
rendered prometheus for cluster local in 218.181125ms
rendered platform in 218.24475ms
```

```bash
git diff deploy
```

```diff
diff --git a/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml b/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml
index ade06a5..9599c26 100644
--- a/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml
+++ b/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml
@@ -609,7 +609,7 @@ data:
       - source_labels:
         - __address__
         target_label: __param_target
-      - replacement: blackbox
+      - replacement: blackbox:80
         target_label: __address__
       - source_labels:
         - __param_target
```

Let's add and commit this change now.

Then let's make sure they really are in lock step.  Let's change the port back
to the blackbox default.

Make this change:

```diff
diff --git a/examples/prometheus/projects/prometheus.cue b/examples/prometheus/projects/prometheus.cue
index 4f83651..acb9e3e 100644
--- a/examples/prometheus/projects/prometheus.cue
+++ b/examples/prometheus/projects/prometheus.cue
@@ -14,5 +14,5 @@ package holos
 // Concrete values
 _Prometheus: #Prometheus & {
        BlackboxServiceName: "blackbox"
-       BlackboxServicePort: 80
+       BlackboxServicePort: 9115
 }

```

Render the platform

```
holos render platform ./platform
```

Both helm charts fully render in lock step now:

```bash
git diff deploy
```

```diff
diff --git a/examples/prometheus/deploy/clusters/local/components/blackbox/blackbox.gen.yaml b/examples/prometheus/deploy/clusters/local/components/blackbox/blackbox.gen.yaml
index 276e3fa..c3484f2 100644
--- a/examples/prometheus/deploy/clusters/local/components/blackbox/blackbox.gen.yaml
+++ b/examples/prometheus/deploy/clusters/local/components/blackbox/blackbox.gen.yaml
@@ -54,7 +54,7 @@ metadata:
 spec:
   ports:
   - name: http
-    port: 80
+    port: 9115
     protocol: TCP
     targetPort: http
   selector:
diff --git a/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml b/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml
index 9599c26..348c886 100644
--- a/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml
+++ b/examples/prometheus/deploy/clusters/local/components/prometheus/prometheus.gen.yaml
@@ -609,7 +609,7 @@ data:
       - source_labels:
         - __address__
         target_label: __param_target
-      - replacement: blackbox:80
+      - replacement: blackbox:9115
         target_label: __address__
       - source_labels:
         - __param_target

```

Let's apply these two manifest files to our cluster.

```bas
kubectl apply \
  -f deploy/clusters/local/components/prometheus/prometheus.gen.yaml \
  -f deploy/clusters/local/components/blackbox/blackbox.gen.yaml
```

```txt
serviceaccount/prometheus-alertmanager created
serviceaccount/prometheus-kube-state-metrics created
serviceaccount/prometheus-prometheus-node-exporter created
serviceaccount/prometheus-prometheus-pushgateway created
serviceaccount/prometheus-server created
clusterrole.rbac.authorization.k8s.io/prometheus-kube-state-metrics created
clusterrole.rbac.authorization.k8s.io/prometheus-server created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-server created
configmap/prometheus-alertmanager created
configmap/prometheus-server created
service/prometheus-alertmanager created
service/prometheus-alertmanager-headless created
service/prometheus-kube-state-metrics created
service/prometheus-prometheus-node-exporter created
service/prometheus-prometheus-pushgateway created
service/prometheus-server created
persistentvolumeclaim/prometheus-server created
deployment.apps/prometheus-kube-state-metrics created
deployment.apps/prometheus-prometheus-pushgateway created
deployment.apps/prometheus-server created
statefulset.apps/prometheus-alertmanager created
daemonset.apps/prometheus-prometheus-node-exporter created
serviceaccount/blackbox created
configmap/blackbox created
service/blackbox created
deployment.apps/blackbox created
```

Looks good:

```bash
kubectl get svc
```
```txt
NAME                                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
blackbox                              ClusterIP   10.43.138.179   <none>        9115/TCP   104s
kubernetes                            ClusterIP   10.43.0.1       <none>        443/TCP    3m2s
prometheus-alertmanager               ClusterIP   10.43.112.160   <none>        9093/TCP   104s
prometheus-alertmanager-headless      ClusterIP   None            <none>        9093/TCP   104s
prometheus-kube-state-metrics         ClusterIP   10.43.56.40     <none>        8080/TCP   104s
prometheus-prometheus-node-exporter   ClusterIP   10.43.29.207    <none>        9100/TCP   104s
prometheus-prometheus-pushgateway     ClusterIP   10.43.132.67    <none>        9091/TCP   104s
prometheus-server                     ClusterIP   10.43.27.187    <none>        80/TCP     104s
```

We still need to deploy the httpbin pod though.  Holos also makes it easy to
integrate Kustomize bases along side helm charts.

```bash
mkdir -p projects/platform/components/httpbin
```

A kustomize component looks like this.  We don't need to write a
`kustomization.yaml` file, Holos will take care of writing it out from what we
define in CUE.

```bash
cat <<EOF >projects/platform/components/httpbin/httpbin.cue
package holos

// Produce a Kustomize BuildPlan for Holos
_Kustomize.BuildPlan

// https://github.com/mccutchen/go-httpbin/blob/v2.15.0/kustomize/README.md
_Kustomize: #Kustomize & {
	KustomizeConfig: Resources: "github.com/mccutchen/go-httpbin/kustomize": _
	KustomizeConfig: Kustomization: commonLabels: "app.kubernetes.io/name": "httpbin"
}
EOF
```

The above is equivalent to a static `kustomization.yaml` file that looks like
the following, but now it's in CUE so we can inject data easily when we need to.

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
commonLabels:
  app.kubernetes.io/name: httpbin
resources:
  - github.com/mccutchen/go-httpbin/kustomize
```

We need to register the component with the platform.

```bash
cat <<EOF >platform/httpbin.cue
package holos

// Manage the Component on every Cluster in the Platform
for Fleet in _Fleets {
	for Cluster in Fleet.clusters {
		_Platform: Components: "\(Cluster.name):httpbin": {
			name:      "httpbin"
			component: "projects/platform/components/httpbin"
			cluster:   Cluster.name
		}
	}
}
EOF
```

Render the platform and we have a third fully rendered manifest.

```bash
holos render platform ./platform
```

```txt
rendered blackbox for cluster local in 179.023333ms
rendered prometheus for cluster local in 221.369708ms
rendered httpbin for cluster local in 1.4167515s
rendered platform in 1.416865708s
```

```bash
tree deploy 
```
```
deploy
└── clusters
    └── local
        └── components
            ├── blackbox
            │   └── blackbox.gen.yaml
            ├── httpbin
            │   └── httpbin.gen.yaml
            └── prometheus
                └── prometheus.gen.yaml
```
