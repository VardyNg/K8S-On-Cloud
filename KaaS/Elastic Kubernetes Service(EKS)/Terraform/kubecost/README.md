## Deploy an EKS Cluster with Kubecost

This example deploy [Kubecosts](https://www.kubecost.com/) specifily for EKS clusters, using the Helm Chart as described in [AWS doc](https://docs.aws.amazon.com/eks/latest/userguide/cost-monitoring-kubecost.html).

After deploying, modify the `kubecost-cost-analyzer` and `kubeocost-prometheus` Deployments, remove the volum PVC usage and replace with `emptyDir: {}` instead, as it is just a demo.

Then, run the following command to port-forward the Kubecost UI to your local machine:

```bash
kubectl port-forward service/kubecost-cost-analyzer 9090:9090
```

Then, open your browser and navigate to `http://localhost:9090` to view the Kubecost UI.

