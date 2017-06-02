# Deployments

> **Do not forget to set your Kubernetes context _first_ by following the [setting-context](setting-context.md) documentation**

## tl;dr

**Create a Deployment**

> $ kubectl run example-app --image=quay.io/reactiveops/example-app --replicas=3 --generator=deployment/v1beta1

**Watch the Deployment status**

> $ kubectl rollout status deployment/example-app 

**Update the Deployment**

> $ kubectl set image deployment/example-app --container=example-app --image=quay.io/reactiveops/example-app:_some-version_

**Pause the Deployment**

> $ kubectl rollout pause deployment/example-app

**Resume the Deployment**

> $ kubectl rollout resume deployment/example-app

**Check the change history (deployment revisions)**

> $ kubectl rollout history deployment/example-app
>
> $ kubectl rollout history deployment/example-app --revision=_N_

**Rollback to a previous version**

> $ kubectl rollout undo deployment/example-app
> 
> $ kubectl rollout undo deployment/example-app --to-revision=_N_

## Writing a Deployment File

Templated `Deployment` files have been created to give a good starting point.

Example application `Deployment`:

[example-app.deployment.yml](kubernetes-templates/example-app.deployment.yml)

Example worker `Deployment`:

[example-worker.deployment.yml](kubernetes-templates/example-worker.deployment.yml)

Lots of customization can be done based on the specifics of the application or worker in question.

Of note:

- `replicas`: number of copies of the defined Pod you would like to maintain
- `template`: template of the Pod you would like to create for this Deployment
  - `imagePullSecrets`: name of the Kubernetes Secret used to connect to the private Docker registry (in this case quay.io) to allow Kubernetes to pull the image
  - `image`: quay.io url of Docker image for your application
  - `containerPort`: port of the application running in your container 
  - `livenessProbe` and `readinessProbe`: define healthchecks for your container
  - `env`: environmental variables with which to start the Pod
	  - notice that most env vars are injected via a `configMapKeyRef` or `secretKeyRef` which belong to corresponding Kubernetes `ConfigMap` and `Secret` resources
	  - defining variables in a Kubernetes `ConfigMap` or `Secret` will allow you to reuse this information across Deployments

For more options available for use in Deployments, see > [http://kubernetes.io/docs/user-guide/deployments/#writing-a-deployment-spec](http://kubernetes.io/docs/user-guide/deployments/#writing-a-deployment-spec)

## Create a Deployment

The following command will take the `Deployment` configuration you've written from the file you specify and create a `Deployment` resource within the namespace you specify. 

```
$kubectl create -f example-app.deployment.yaml --record
deployment "example-app" created
```

## Watch the Deployment Status

After creating or updating a `Deployment`, you would want to confirm whether it succeeded or not. The simplest way to do this is through `kubectl rollout status`.

```
$kubectl rollout status deployment/example-app
deployment example-app successfully rolled out
```

This verifies the `Deployment`’s .status.observedGeneration >= .metadata.generation, and its up-to-date replicas (.status.updatedReplicas) matches the desired replicas (.spec.replicas) to determine if the rollout succeeded. 

If the rollout is still in progress, it watches for `Deployment` status changes and prints related messages.

```
$kubectl rollout status deployment/example-app
Waiting for rollout to finish: 2 out of 3 new replicas have been updated...
deployment example-app successfully rolled out
```

If the above command doesn’t return success, you’ll need to timeout and give up at some point.

```
$kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
example-app   3         3         3            3           20s
```

## Update the Deployment

A `Deployment`’s rollout is triggered if and only if the `Deployment`’s pod template (i.e. .spec.template) is changed, e.g. updating labels or container images of the template. **Other updates, such as scaling the `Deployment`, will not trigger a rollout.**

Suppose that we now want to update the example-app Pods to start using the example-app:1.0.0 image instead of the example-app:1.0.1 image.

```
$kubectl set image deployment/example-app --container=example-app --image=quay.io/reactiveops/example-app:1.0.1 
deployment "example-app" image updated
```

Alternatively, we can edit the `Deployment` and change .spec.template.spec.containers[0].image from example-app:1.0.0 to example-app:1.0.1:

```
$kubectl edit deployment/example-app
deployment "example-app" edited
```

We can run `kubectl get rs` to see that the `Deployment` updated the `Pods` by creating a new `Replica Set` and scaling it up to 3 replicas, as well as scaling down the old Replica Set to 0 replicas.

```
$kubectl get rs
NAME                          DESIRED   CURRENT   AGE
example-app-1564180365   3         3         6s
example-app-2035384211   0         0         36s
```

Running get pods should now show only the updated `Pods`

```
$kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
example-app-1564180365-khku8   1/1       Running   0          14s
example-app-1564180365-nacti   1/1       Running   0          14s
example-app-1564180365-z9gth   1/1       Running   0          14s
```

## Pausing and Resuming the Deployment

You can also pause a `Deployment` mid-way and then resume it. A use case is to support canary deployment.

```
$kubectl set image deployment/example-app --container=example-app --image=quay.io/reactiveops/example-app:1.0.1; kubectl rollout pause deployment/example-app
deployment "example-app" image updated
deployment "example-app" paused
```

Note that any current state of the `Deployment` will continue its function, but new updates to the `Deployment` will not have an effect as long as the `Deployment` is paused.

The `Deployment` was still in progress when we paused it, so the actions of scaling up and down Replica Sets are paused too.

```
$kubectl get rs
NAME                          DESIRED   CURRENT   AGE
example-app-1564180365   2         2         1h
example-app-2035384211   2         2         1h
example-app-3066724191   0         0         1h
```

To resume the `Deployment`, simply do `kubectl rollout resume`

```
$kubectl rollout resume deployment/example-app
deployment "example-app" resumed
```

Then the `Deployment` will continue and finish the rollout

```
$ kubectl rollout status deployment/example-app
Waiting for rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment spec update to be observed...
Waiting for rollout to finish: 2 out of 3 new replicas have been updated...
deployment example-app successfully rolled out
```

## Check the change history (deployment versions)

To check the revisions of this deployment use `kubectl rollout history`

Because we recorded the command while creating this Deployment using `--record`, we can easily see the changes we made in each revision.

```
$kubectl rollout history deployment/example-app
deployments "example-app":
REVISION    CHANGE-CAUSE
1           kubectl create -f example-app.deployment.yaml --record
2           kubectl set image deployment/example-app example-app=quay.io/reactiveops/example-app:1.0.1
3           kubectl set image deployment/example-app example-app=quay.io/reactiveops/example-app:1.0.1
```

To see more details for each revision

```
$ kubectl rollout history deployment/example-app --revision=2
deployments "example-app" revision 2
  Labels:       app=example-app
          pod-template-hash=1159050644
  Annotations:  kubernetes.io/change-cause=kubectl set image deployment/example-app example-app=quay.io/reactiveops/example-app:1.0.1
  Containers:
   example-app:
    Image:      quay.io/reactiveops/example-app:1.0.1
    Port:       80/TCP
     QoS Tier:
        cpu:      BestEffort
        memory:   BestEffort
    Environment Variables:      <none>
  No volumes.

```

## Rollback to a previous version

To undo a `Deployment` rollout and rollback to the previous revision

```
$kubectl rollout undo deployment/example-app
deployment "example-app" rolled back
```

To rollback to a specific revision by specify that in --to-revision

```
$ kubectl rollout undo deployment/example-app --to-revision=2
deployment "example-app" rolled back
```

The `Deployment` is now rolled back to a previous stable revision. As you can see, a `DeploymentRollback` event for rolling back to revision 2 is generated from `Deployment` controller.

```
$ kubectl describe deployment 
Name:           example-app
Namespace:      default
CreationTimestamp:  Tue, 22 Nov 2016 13:11:07 -0500
Labels:         app=example-app
Selector:       app=example-app
Replicas:       3 updated | 3 total | 3 available | 0 unavailable
StrategyType:       RollingUpdate
MinReadySeconds:    0
RollingUpdateStrategy:  1 max unavailable, 1 max surge
OldReplicaSets:     <none>
NewReplicaSet:      example-app-1564180365 (3/3 replicas created)
Events:
  FirstSeen LastSeen    Count   From                    SubobjectPath   Type        Reason              Message
  --------- --------    -----   ----                    -------------   --------    ------              -------
  30m       30m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled up replica set example-app-2035384211 to 3
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled up replica set example-app-1564180365 to 1
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled down replica set example-app-2035384211 to 2
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled up replica set example-app-1564180365 to 2
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled down replica set example-app-2035384211 to 0
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled up replica set example-app-3066724191 to 2
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled up replica set example-app-3066724191 to 1
  29m       29m         1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled down replica set example-app-1564180365 to 2
  2m        2m          1       {deployment-controller }                Normal      ScalingReplicaSet   Scaled down replica set example-app-3066724191 to 0
  2m        2m          1       {deployment-controller }                Normal      DeploymentRollback  Rolled back deployment "example-app" to revision 2
  29m       2m          2       {deployment-controller }                Normal      ScalingReplicaSet   Scaled up replica set example-app-1564180365 to 3
```


## Deployment Clean up Policy

Inside your `Deployment` you can set .spec.revisionHistoryLimit field to specify how much revision history of a particular `Deployment` you want to keep. By default, all revision history will be kept; explicitly setting this field to 0 disallows a deployment being rolled back.

