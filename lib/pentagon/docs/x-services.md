
# Kubernetes Services

Not all service attributes are updated in Kubernetes after deployment. If that is the case then recreating the resource will be needed. 

## Services and Consul8s

With Consul registration you won't be able to update services atomically. To avoid an outage you must deregister the service from Consul (`deregister: "true"` in service config), then can remove the Kubernetes Service.

[Consul8s](https://github.com/reactiveops/consul8s) is designed to fail instead of swallow errors. This can be dangerous in that it may not keep everything up to date. It will stop before it causes harm though if there is an error.

Consul services with 0 endpoints are an error for consul8s. 

[A Consul8s exit can be used for monitoring](https://github.com/reactiveops/consul8s#monitoring) when `--prometheus` flag is used.
