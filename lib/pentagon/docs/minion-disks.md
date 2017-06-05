# Minion Disks

Kubernetes can run out of disk space on individual minions, this is called “[disk pressure](https://kubernetes.io/docs/tasks/administer-cluster/out-of-resource/)” by Kubernetes. In practice we have not seen Kubernetes react quickly enough to clean up disks before this becomes a problem. 

We've put in 100gb disks for the minions but may increase them. We run [docker-gc](https://github.com/spotify/docker-gc) to help clean up disks proactively instead of as we run out of disk. 
