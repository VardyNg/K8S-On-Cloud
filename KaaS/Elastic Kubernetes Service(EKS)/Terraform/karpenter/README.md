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

### Troubeshooting
- Terraform plan/apply fail duie to REST
  ```sh
  ╷
  │ Error: Failed to construct REST client
  │ 
  │   with kubernetes_manifest.karpenter_ec2nodeclass,
  │   on karpenter.tf line 54, in resource "kubernetes_manifest" "karpenter_ec2nodeclass":
  │   54: resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  │ 
  │ cannot create REST client: no client config
  ╵
  ╷
  │ Error: Failed to construct REST client
  │ 
  │   with kubernetes_manifest.karpenter_nodepool,
  │   on karpenter.tf line 120, in resource "kubernetes_manifest" "karpenter_nodepool":
  │  120: resource "kubernetes_manifest" "karpenter_nodepool" {
  │ 
  │ cannot create REST client: no client config
  ╵
  ```
  Since this resource require API access, Terraform need the API, i.e. the EKS cluster to be ready during plan staged. 

  Therefore, comment out this section and apply again when the rest of the deployment is completed

  Reference: https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775#issuecomment-1185725432

  Idea wanted!