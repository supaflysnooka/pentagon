# HOWTO

## How do I setup my workstation to use kubectl?

See [Installing and Setting up kubectl](setup-kubectl.md)

## How do I choose which cluster to communicate with?

**Staging (v1.4)**

`$ kubectl config use-context staging`

**Production (v1.4)**

`$ kubectl config use-context production`

## How do I onboard an application?

See [Onboard an application](application-lifecycle.md#onboard-an-application)

## How do I deploy an application build?

See [Deploy an application build](application-lifecycle.md#deploy-an-application-build)

## Is there an easy way for me to visualize what is going on?

Each cluster has a UI addon installed and is available via https with the user credentials (username/password) inside the kubeconfig.

**working.k8s.reactiveops.com (v1.4)**

`https://api.working.k8s.reactiveops.com/ui`

**production.k8s.reactiveops.com (v1.4)**

`https://api.production.k8s.reactiveops.com/ui`

**Note**: once connected to the UI of the physical cluster you are interested in, the namespaces (`working`,`production`) are available via a dropdown box on the left-hand side menu.