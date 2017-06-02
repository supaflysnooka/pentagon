# Setting Kubernetes Context

## tl;dr

Global context

>`kubectl config use-context <context>`

Command context

>`--context <context>`
>
>`--namespace=<namespace> --cluster=<cluster>`

## Clusters and Namespaces

Since the environment currently plays host to several

physical **clusters**:
- Kubernetes v1.4.x (kops): `working.k8s.reactiveops.com` 
- Kubernetes v1.4.x (kops): `production.k8s.reactiveops.com`

and namespaces: 
- `staging`
- `production`

it is important to be explicit about which combination you will be interacting with.

On the command line, you can specify Kubernetes context in two ways:

1. use the command `kubectl config use-context CONTEXT_NAME` to set the context for all commands henceforth
2. append `--namespace` and `--context` flags to each `kubectl` command

The former method is more useful when you will be running many commands within the same context (e.g. troubleshooting a Deployment). The latter is useful when comparing commands across multiple namespaces or clusters (e.g. taking stock of cluster resources used)

## Global Context

The global Kubernetes Config (kubeconfig) is maintained within a file.  

This is usually kept in `~/.kube/config`

but can also be loaded via ENV by `export KUBECONFIG=/path/to/kube/config`.  

This file contains many secrets, including certificates, tokens, usernames and passwords.  It should be treated as high-risk information and handled as securely as possible

The kubeconfig also contains information about `context`.  A context defines a named **cluster**, **user**, **namespace** tuple which is used to send requests to the specified cluster using the provided authentication info and namespace. Each of the three pieces is optional; it is valid to specify a context with only one of cluster, user, namespace, or to specify none.  Unspecified values, or named values that don’t have corresponding entries will be replaced with the default. 


### Add a Context

To define or set a context entry in kubeconfig, use `kubectl config set-context`, specify the desired name of the context, as well as the defining features (`--cluster`, `--user` and/or `--namespace`).

Specifying a name that already exists will merge new fields on top of existing values for those fields.

Example:

```
$kubectl config set-context staging --cluster=working.k8s.reactiveops.com --namespace=staging
```

### Use a Context

To use an already defined context, run the `kubectl config use-context` command and specify the desired context name.  This will ensure that any `kubectl` commands run from that point forward will be applied that that specific context.

Example:

```
$kubectl config use-context staging
```

### Display current Context

To display the current context in use, run `kubectl config current-context`

Example:

```
$ kubectl config current-context
staging
```

## Command Context

Setting the kubectl flag `--namespace` allows you to deploy to a specific virtual cluster you'd like to interact with. Namespaces provide a scope for names. Names of resources need to be unique within a namespace, but not across namespaces. Therefore, you can create the same `Deployment` in multiple namespaces.

Setting the kubectl flag `--cluster` allows you to specify the physical Kubernetes cluster you'd like to interact with. 

Setting the kubectl flag `--context` allows you to directly specify the context (combination of `cluster`, `namespace`, `user`) you'd like to interact with.  See above section for adding/defining new contexts. 

**v1.4 Staging**

>`--context=staging`
>
>`--namespace=staging --cluster=working.k8s.reactiveops.com`

**v1.4 Production**
>`--context=production`
>
>`--namespace=production --cluster=production.k8s.reactiveops.com`
