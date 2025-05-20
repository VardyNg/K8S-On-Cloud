## This template illustrate the use of Cluster Autoscaler (CA)in EKS cluster

### How it works?
- The CA is deployed as a `Deployment` in the `kube-system` namespace, it monitor the Kubernetes API server for new nodes and pods, and it automatically scales the number of nodes in the cluster based on the resource requests of the pods.
- The CA is granted permission to monitor the cluster via a `ClusterRole` and `ClusterRoleBinding`.
- The CA is granted permission to adjust the Autoscaling Group via an IAM role, i.e. through IRSA (IAM Roles for Service Accounts).

### How Cluster Autoscaler disover the ASG?
1. Specify the ASG in the `--nodes` flag of the CA deployment.
1. Use Auto Discovery, by `kubernetes.io/cluster/<CLUSTER NAME>` tag on the ASG. 
### How to test
Scale the deployment up and down to see if the CA is working as expected.

- Scale the "Simple" Deployment
```bash
kubectl scale deploy autoscaling-test-simple --replicas 10
```


- Scale the "NodeSelector" Deployment
```bash
kubectl scale deploy autoscaling-test-node-selector --replicas 10
```

It will only scale the ASG with the matchiung node selector.
