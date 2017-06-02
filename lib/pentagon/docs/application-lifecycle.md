# Application Lifecycle

[Onboard an application](#onboard-an-application)

[Deploy an application build](#deploy-an-application-build)

[Release an application](#release-an-application)

[Rollback an application](#rollback-an-application)

[End-of-life an application](#end-of-life-an-application)

## Onboard an application

1) identify context (cluster + namespace) you would like to target [[see docs](setting-context.md)]

`$ kubectl config use-context staging`

2) define `Secrets` that application will need injected at runtime [[see docs](http://kubernetes.io/docs/user-guide/secrets/#creating-your-own-secrets)]

`$ kubectl apply -f secret.yaml`

3) define `ConfigMap` for non-sensitive environmental variables to inject at runtime [[app configmap template](../kubernetes-templates/example-app-staging.configmap.yml)][[see docs](http://kubernetes.io/docs/user-guide/configmap/)]

`$ kubectl apply -f configmap.yaml --record`

4) write `Service` (if static address/public presence is necessary) based on provided templates. If not behind `cluster-proxy` uncomment ELB configuration line. [[app service template](../kubernetes-templates/example-app.service.yml)] [[docs](http://kubernetes.io/docs/user-guide/services/)]

`$ kubectl create -f service.yaml --record`

5) write `Deployment` based on provided templates. modify at least `name`, `labels`, `image` and `env` vars. see documentation about leveraging Secrets and ConfigMaps in your deployment.
[[app deployment template](../kubernetes-templates/example-app/deployment.yml)] [[worker deployment template](../kubernetes-templates/example-worker/deployment.yml)] [[docs](http://kubernetes.io/docs/user-guide/deployments/)]

`$ kubectl create -f deployment.yaml --record`


## Deploy an application build

1) identify context (cluster + namespace) you would like to target [[see docs](setting-context.md)]

`$ kubectl config use-context staging-secure`

2) update `Secrets`

`$ kubectl apply -f secret.yaml`

3) update `ConfigMaps`

`$ kubectl apply -f configmap.yaml --record`

4) update `Service`

(if exists already and is changing)
```
$ kubectl get service <service-name>
$ kubectl apply -f service.yaml --record
```

or

(if doesn't exist)

`$ kubectl create -f service.yaml --record`

5) update `Deployment`

(if exists already and is changing)

```
$ kubectl get deployment <deployment-name>
$ sed 's/:latest/':${CI_SHA1}'/g;' deployment.yaml > deployment.yaml-${CI_SHA1}
$ kubectl apply -f deployment.yaml-${CI_SHA1}
```

**Note**: `CI_SHA1` here is the build SHA you are deploying. Being explicit about SHA to deploy is best practice (instead of using latest).

(if doesn't exist)

`$ kubectl create -f deployment.yaml`

6) wait for `Deployment` to finish successfully. watch for `updatedReplicas` and `availableReplicas`

`$ kubectl get deployment <deployment-name> -o yaml`


## Release an application

The patterns currently used with Kubernetes make no distinction between a deployment to `production` or `secure-production` and a "release."  

`Deployments` are not currently immutable in the sense that there is not a new, unique `Deployment` resource with a unique identifier created for each deploy.  

Rather, the `Deployment` resource for a particular application/service is updated with a new `image` (identified by SHA) and applied in-place.  Using this method, Kubernetes detects the change in `Deployment` and spawns a new `Replica Set` which spawns the new `Pods`.  

The `Service` resource, which provides the static IP/ELB interface for the new `Pods`, selects its backend resources by `selector`.  This `selector` field defines a label used to identify the correct backing application `Pods`. These labels to not change between deployment and so the label selector is also static.  

All of this adds up to the fact that there is no real "release" point where a `Service` is cut-over or swapped over to a full set of new `Pods`.  Rather, a `RollingUpdate` is used where the new Pods coming online are added to the Service as older Pods are removed.

### tl;dr

A **release** essentially happens, when `kubectl apply -f deployment.yaml-${CI_SHA}` is run in one of the production contexts

If a different solution is needed, it may be useful to look in to deploying with a certain label that is attached to a private `Service` and then modifying labels when the release happens. If the modified label is attached to a public `Service`, this may be sufficient, though a method to roll-off older `Pods` would also be needed`.

## Rollback an application

1) identify context (cluster + namespace) you would like to target [[see docs](setting-context.md)]

`$ kubectl config use-context staging-secure`

2) check the change history (deployment revisions)

`$ kubectl rollout history deployment/example-app`

`$ kubectl rollout history deployment/example-app --revision=_N_`

3) rollback to a previous revision

`$ kubectl rollout undo deployment/example-app`

`$ kubectl rollout undo deployment/example-app --to-revision=_N_`

4) wait for undo to finish successfully. watch for `updatedReplicas` and `availableReplicas`

`$ kubectl get deployment <deployment-name> -o yaml`

## End-of-life an application

1) identify context (cluster + namespace) you would like to target [[see docs](setting-context.md)]

`$ kubectl config use-context staging-secure`

2) remove `Secrets`

`$ kubectl delete -f secret.yaml`

3) remove `ConfigMaps`

`$ kubectl delete -f configmap.yaml --record`

4) remove `Services`

`$ kubectl delete -f service.yaml --record`

5) remove `Deployments`

`$ kubectl delete -f deployment.yaml --record`

6) clean up old `ReplicaSets`

```
$ for r in `kubectl get rs | grep <deployment-name> | awk '{print $1}'` ; do kubectl delete replicaset/$r; done
```