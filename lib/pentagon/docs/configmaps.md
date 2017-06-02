# ConfigMaps

> **Do not forget to set your Kubernetes context _first_ by following the [setting-context](setting-context.md) documentation**

## tl;dr


**Create a ConfigMap from a ConfigMap document**

> `$ kubectl apply -f example-app-staging.configmap.yml --record`

**Create a ConfigMap from a file of key-value pairs**


> `$ kubectl create configmap example-app --from-file=example-app-staging.configmap.yml --record`

**Create a ConfigMap from literal values**

> `$ kubectl create configmap example-app --from-literal=rails_env=staging --from-literal=rack_env=staging --record`

**Consume ConfigMap values in a pod**

```      
	env:
        - name: RAILS_ENV
          valueFrom:
            configMapKeyRef:
              name: example-app
              key: rails_env
        - name: RACK_ENV
          valueFrom:
            configMapKeyRef:
              name: example-app
              key: rack_env

```

**Update a ConfigMap and restart Pod to pick up changes**

> `$ kubectl apply -f example-app-staging.configmap.yml`
>
> `$kubectl patch deployment example-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"example-app","env":[{"name":"RESTART_","value":"'$(date +%s)'"}]}]}}}}'`


## Writing a ConfigMap

Many applications require configuration via some combination of config files, command line arguments, and environment variables. These configuration artifacts should be decoupled from image content in order to keep containerized applications portable. 

The ConfigMap API resource provides mechanisms to inject containers with configuration data while keeping containers agnostic of Kubernetes. ConfigMap can be used to store fine-grained information like individual properties or coarse-grained information like entire config files or JSON blobs.

The ConfigMap API resource holds key-value pairs of configuration data that can be consumed in pods or used to store configuration data for system components such as controllers. ConfigMap is similar to Secret, but designed to more conveniently support working with strings that do not contain sensitive information.

Example:

`example-app-staging.configmap.yml`

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-app
data:
  db-host:                     'example-db.example.com'
  db-username:                 'example-db-user'
  db-database-name:            'example-app'
  rack-env:                    'staging'
  rails-env:                   'staging'
```

## Creating a ConfigMap from a file

When creating a ConfigMap from an existing file, we can use one of two formats
1. a well formed, complete Kubernetes ConfigMap document
2. a plain text file of key-value pairs

### From a well formed, complete ConfigMap document

A ConfigMap document is written in YAML, as with other Kubernetes resources, and provides both the data and metadata for the ConfigMap object being created. By writing your own ConfigMap document, you have the power to format the data structure however you need it to be nested, formated, etc. You can also be explicit about the metadata, labels, etc attributed to it.

Example:

`example-app-staging.configmap.yml`

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-app
data:
  db-host:                     'example-db.example.com'
  db-username:                 'example-db-user'
  db-database-name:            'example-app'
  rack-env:                    'staging'
  rails-env:                   'staging'
```

Since the ConfigMap document is essentially already created, we use the `kubectl apply` command rather than create.

`$kubectl apply -f example-app-staging.configmap.yml --record`

```
$ kubectl get configmaps example-app -o yaml
apiVersion: v1
data:
  db-host='example-db.example.com'
  db-username='example-db-user'
  db-database-name='example-app'
  rack-env='staging'
  rails-env='staging'
kind: ConfigMap
metadata:
  creationTimestamp: 2016-11-23T21:57:56Z
  name: example-app
...
```

### From a file of key-value pairs

A plain-text file with key-value pairs can provide the necessary information to populate a ConfigMap. Ensure that there is one key-value pair per line, and quote values properly.

```
$ cat example-app.properties
db-host='example-db.example.com'
db-username='example-db-user'
db-database-name='example-app'
rack-env='staging'
rails-env='staging'
```

Now, run `kubectl create configmap` with a desired name for the ConfigMap and the source file we created above.

`$ kubectl create configmap example-app --from-file=example-app.properties`

```
$ kubectl get configmaps example-app -o yaml
apiVersion: v1
data:
  example-app.properties: |-
    db-host='example-db.example.com'
    db-username='example-db-user'
    db-database-name='example-app'
    rack-env='staging'
    rails-env='staging'
kind: ConfigMap
metadata:
  creationTimestamp: 2016-11-23T11:32:22Z
  name: example-app
  namespace: secure-staging
...
```

ConfigMaps created in such a manner will prefix all the values with the name of the file you've used to seed it. (e.g. `example-app.properties.db-host`) Keep this in mind when consuming ConfigMap values in other resources.

## Create a ConfigMap from literal values

It is also possible to supply literal values for ConfigMaps using kubectl create configmap. The `--from-literal` option takes a key=value syntax that allows literal values to be supplied directly on the command line

`$ kubectl create configmap example --from-literal=db-host=example-db.example.com --from-literal=db-username=example-db-user`

```
$ kubectl get configmaps example-app -o yaml
apiVersion: v1
data:
  db-host='example-db.example.com'
  db-username='example-db-user'
kind: ConfigMap
metadata:
  creationTimestamp: 2016-11-23T11:32:22Z
  name: example-app
  namespace: secure-staging
...
```

As using this method provides little configuration management and auditing options, since no record of the literals used are kept outside of Kubernetes, it is not always the best option.  It may, however, come in handy if scripted to accept values programmatically from other sources.

## Consuming ConfigMap as environment variables

Many programs read their configuration from environment variables. ConfigMap should be possible to consume in environment variables. The rough series of events for consuming ConfigMap this way is:

- A ConfigMap object is created
- A pod that consumes the configuration data via environment variables is created
- The pod is scheduled onto a node
- The kubelet retrieves the ConfigMap resource(s) referenced by the pod and starts the container processes with the appropriate data in environment variables


## Update a ConfigMap and consume new values


### From a well formed, complete ConfigMap document

If you have a complete ConfigMap document that lives under configuration management, it is quite easy to update ConfigMap values.  First, edit the document you wish to change and save it.  In the following example we will modify the `db-host` and `db-username`:

`example-app-staging.configmap.yml`

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-app
data:
  db-host:                     'db.example.com'
  db-username:                 'db-user'
  db-database-name:            'example-app'
  rack-env:                    'staging'
  rails-env:                   'staging'
```

Now, we need to apply the changes, this involves using the `kubectl apply` command and specifying the newly saved file, to apply changes.

`$ kubectl apply -f example-app-staging.configmap.yml`

If we take a look at our modified configmap using `kubectl get configmaps` we can see that the values have been updated properly. Furthermore, annotations will have been added to the metadata showing what changes have been made and by what method.  

```
$ kubectl get configmaps example-app -o yaml
apiVersion: v1
data:
  db-host='db.example.com'
  db-username='db-user'
  db-database-name='example-app'
  rack-env='staging'
  rails-env='staging'
kind: ConfigMap
metadata:
  creationTimestamp: 2016-11-23T11:32:22Z
  name: example-app
  namespace: secure-staging
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: '...'
    kubernetes.io/change-cause: kubectl apply -f example-app-staging.configmap.yml
...
```

Finally, we'll need to ensure that `Pods` and containers that have already been deployed are updated with the new values in the updated ConfigMap.  Since containers must be recreated to pick up new ENV vars, we must destroy those currently running and create new ones.  This can be done in several dirty ways, and Kubernetes does not currently (as of v1.4) have a good way to do a rolling update with `Deployments`.  

Therefore we choose to use a workaround which does and in-place update of the existing deployment and causes a new `ReplicaSet` to be spawned and thus new `Pods` with the new config values.

Using the `kubectl patch deployment` command, we take the dummy ENV variable `RESTART_` which should exist in the `Deployment` (those created from the latest [template](../kubernetes-templates/example-app.deployment.yml) should already include this variable), and we set its value to the current `date`. The command looks something like the following:

```
$kubectl patch deployment example-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"example-app","env":[{"name":"RESTART_","value":"'$(date +%s)'"}]}]}}}}'
```
