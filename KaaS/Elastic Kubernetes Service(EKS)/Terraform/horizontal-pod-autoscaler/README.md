### This example demo the Horizontal Pod Autoscaler (HPA) using Terraform

### The K8S Resources are created following this document: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
#### Step to trigger the HPA
1. Install the [metrics server](https://github.com/kubernetes-sigs/metrics-server)
  ``bash
  $ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml
  ```
1. Trigger HPA by increase workload in exisitng Pods

  ```bash
  $ kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
  ```

  At the same time, monitor the HPA status by running the following command:
  ```bash
  $ watch kubectl get hpa
  ```

  The HPA will scale up the Pods (max 10 replicas) until the average CPU utilization of the Pods is below target (50%).

1. It will automatically scale down the Pods when the average CPU utilization is below target (50%).

  ```bash
  $ kubectl delete pod load-generator
  ```

  HPA will scale down the Pods to the minimum replicas.
