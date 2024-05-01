### This template demostrate the use of EKS Pod mount EFS Volume (Dynamic Provisioning)

### Content
- VPC, Subnet, Security Group ... for the EKS cluster
- an EKS cluster (v1.29) and a Managed Node Group
  - Add-on `aws-efs-csi-driver`
- IAM Role for the add-on aws-efs-csi-driver (`aws_iam_role.efs_role"`) (IRSA)
- IAM policy attached to the role and allow listing s3 buckets (`"aws_iam_policy.efs_controller"`)
- Kubernetes namespace, storage calss, pvc, and sample deployment (see [k8s.tf](k8s.tf))

### Reference:
https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/master/examples/kubernetes/dynamic_provisioning

### Verify the set up
A Deployment will deploys pods, use the following command to see the file that written by the pods  
There should be multiple file with the time stamp as name
```sh
kubectl exec <pod-name> -n pod-mount-efs-volume-namespace -- bash -c "cat data/out"
```

### Deploy
```sh
terraform apply
```

### Clean up

```sh
terraform destroy
```