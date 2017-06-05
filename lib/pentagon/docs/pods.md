# Pods

`killing`, `replacing`, `restart` a pod means to terminate it and allow Kubernetes to replace it. There isn’t a way to actually “restart” a pod in Kubernetes.  This can be done in the Dashboard UI via the “Delete” action on a pod or with `kubectl delete pod $POD`.


## Liveness 

Strive to have the container exit if the process is broken and allow Kubernetes to replace the pod. 

Use `minReadySeconds` for longer than a normal startup time to make sure Kubernetes doesn’t think startup time counts as successful running time.

Include a `livenessProbe` for web/socket applications. Daemons are a bit harder and benefit from the above-mentioned exiting if things are not working. 


## Images

The pod’s `spec.containers[].image` field specifies the image to be used for the pod. It is best to use a tag for the image that will not be re-tagged/reused. `rok8s-scripts` will turn the `latest` tag into the `$CI_SHA1` to help with this. 

Using the `latest` (without `rok8s-scripts`) or any branch tag can lead to problems. Kubernetes will pull images only if they don’t exist already in that Docker instance. If you reused the image you would need to use `imagePullPolicy` to always pull the image, taking more time to roll out the deployment. Without `imagePullPolicy: always` you could run into multiple versions deployed depending on the current version at the time the Kubernetes node first pulled the image. 

Using `latest` in particular can cause problems as `latest` could be from any build, not just `latest` on the `master` branch.

## Multi-Container Pods

Avoid them: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/
single container failures could still be a successful pod, which will deploy "successfully"
