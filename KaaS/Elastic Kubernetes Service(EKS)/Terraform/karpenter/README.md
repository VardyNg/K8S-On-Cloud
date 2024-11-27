## This template shows the installation of Karpenter in the cluster

### Install the metric server
```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Test the autoscaling
Adjust the deployment replicas
```sh
kubectl scale deplyoment --replicas=10 autoscaling-test
```

Observe the node scaling