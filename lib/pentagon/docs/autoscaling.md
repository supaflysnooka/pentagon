# Autoscaling

Autoscaling for Kubernetes can be broken into 2 groups, cluster autoscaling and pod autoscaling.
**With both mechanisms it is required that you use** [**resource requests**](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) **for all* pods**.

*Not really ALL. Daemonsets could be a good reason not to include requests, there may be others. If you don’t have a great reason to omit resource requests, INCLUDE THEM.
****
## Cluster Autoscaling

The Kubernetes cluster is scaled using the [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler). There is [an alternative](https://github.com/hjacobs/kube-aws-autoscaler) we may try eventually.

The Autoscaler (or similar mechanism) is needed as **standard ASG scaling metrics will not work well with Kubernetes**. The use of requests/limits (critical to good operation of the Kubernetes scheduler) means that the actual CPU/memory usage of an instance it not a good indicator of when to scale the cluster. It is possible that the Kubernetes scheduler believes all resources are allocated (and needs more) but the actual CPU usage is very low.

Example:


- Cluster has 3000m CPU available.
- 5 pods are deployed each with 500m CPU requested (2500m in use). 
- These apps aren’t use, and are actually mostly idle. The EC2 instance average cpu usage is 10%. 
- Attempting to deploy a single pod of 1000m would be 3500m/3000.
- Kubernetes needs to scale, but using EC2 CPU usage wouldn’t tell us that. 

The Cluster Autoscaler uses a control-loop to query for pods that cannot be scheduled. If there are pods that cannot be scheduled the Autoscaler attempts to scale the cluster.  This uses a simplified scheduling algorithm and can be tuned for varied behavior when scaling. 

**The Autoscaler will not scale if there was a recent scaling event**. This leads to the need to tune how much to scale depending on cluster size as the delay between scaling events can mean the cluster is not scaling quickly enough. 

The Cluster Autoscaler configuration needs match the same number of nodes as the actual ASG. Otherwise the Autoscaler may fail to manipulate the ASG.

**Scaling down**
We've seen cases where some nodes are not removed due to kube-system resources being deployed there. This doesn't break anything by not being able to scale down those nodes, just may cost more in smaller clusters where other nodes won’t be removed.

**Changing ASG Sizes**
There are a couple of steps involved with changing the autoscaling size of the cluster

- Edit the instance group `kops edit instancegroup nodes` changing `spec.minSize` and `spec.maxSize` as appropriate.
- Update the `cluster-autoscaler.yml` file in `$CLIENT-infrastructure/default/clusters/$CLUSTER/kubernetes/` for the new ASG size. This should be in the `spec.template.spec.containers[].command` updating the `--nodes` numbers. Apply the file with `kubectl apply -f $FILE`.
- Update the weave connection limit in the `weave.yml` file in `$CLIENT-infrastructure/default/clusters/$CLUSTER/kubernetes/`. This should be larger than the max number of nodes (try 2x the max).  Apply the file with `kubectl apply -f $FILE`.
- Update the cluster `kops update cluster` to review the changes then `kops update cluster --yes` to apply them. 
## Horizontal Pod Autoscaling

With requests/limits in place per-pod there is a need to deploy more (or fewer) pods depending on the current workload. The [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) (HPA) handles setting the number of replicas of a pod. This can use CPU or memory, or a custom metric (although changes depending on Kube version). 

CPU usage is generally a good metric to use.  Resource requests for the pod will need to be high enough to account for the application startup which in smaller scales may dominate the resource usage.  500m is a reasonable minimum to use. 

With HPA you may be able to maintain a single deployment file. In many cases the `replicas` number may be all that changes. If that is the case you can use HPA to set the number (even if it’s static) and maintain only 1 deployment file.


## HPA, Cluster Autoscalers, Deployments, AND YOU!

The HPA and Cluster Autoscaler combine to attempt to properly scale a Kubernetes cluster and the deployed applications. This means that when deploying new code to Kubernetes there may not be enough room for even 1 more pod. Eventually this leads to a scaling event for the ASG but a delay in the deployment. Consequently this is one of the reasons another autoscaler may be more useful, allowing over-provisioning to work around this.

We do not yet have guidelines on how shorten this delay.  There are multiple parameters that can be changed on deployments to alter how many pods are changing at one time that may be able to solve this. 
