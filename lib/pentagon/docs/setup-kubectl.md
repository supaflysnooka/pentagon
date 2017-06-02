# Installing and Setting up kubectl

1) Download a precompiled Kubernetes release `kubernetes.tar.gz` from [https://github.com/kubernetes/kubernetes/releases](https://github.com/kubernetes/kubernetes/releases)

`wget https://github.com/kubernetes/kubernetes/releases/download/v1.4.7/kubernetes.tar.gz`

or 

`curl -O https://github.com/kubernetes/kubernetes/releases/download/v1.4.7/kubernetes.tar.gz`

2) Untar Kubernetes release to a useful location (e.g. /src)

`tar -xvzf kubernetes.tar.gz`

3) copy or move `kubectl` into a directory already in PATH (e.g. /usr/local/bin)

OS X
`$ sudo cp /src/kubernetes/platforms/darwin/amd64/kubectl /usr/local/bin/kubectl`

Linux
`$ sudo cp /src/kubernetes/platforms/linux/amd64/kubectl /usr/local/bin/kubectl`

4) make `kubectl` executable

`$ sudo chmod +x /usr/local/bin/kubectl`

5) retreive kubeconfig file from ReactiveOps. Either place in `~/.kube/config` or other path of your choosing

```
$ sudo mkdir -p ~/.kube
$ cp reactiveops.config ~/.kube/config
```

If you choose a different path make sure you set an environment variable to mark its location

`$ export KUBECONFIG=/path/to/kube/config`

6) ensure `kubectl` is configured and communicating properly with clusters

`$ kubectl cluster-info`

**Note: this will show the cluster in current context**