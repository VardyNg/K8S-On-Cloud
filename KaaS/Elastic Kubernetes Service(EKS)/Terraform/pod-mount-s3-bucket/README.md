### This template demostrate mounting EBS Volume with EKS Pods

### Content
- VPC, Subnet, Security Group ... for the EKS cluster
- an EKS cluster (v1.29) and a Managed Node Group
- IAM Role for ebs driver (`aws_iam_role.ebs_role`)
- Kubernetes namespace, storage class, presistent volume, and sample pod (see [k8s.tf](k8s.tf))


### Verify the set up
A Deployment will deploys pods, use the following command to see the file that written by the pods  
There should be multiple file with the time stamp as name
```sh
kubectl exec <pod-name> -n pod-mount-ebs-volume-namespace -- bash -c "cat data/out"
```

### Notes:
- Storage Class cannot set volume_binding_mode = "WaitForFirstConsumer", as its PVC will stay in `Pending` and Terraform think it is still creating, then the deployment won't be applied as it depends on the pvc
- Using EBS, only `ReadWriteOnce` is supported, as EBS can only mount in one node a time, so only one node can read and write the volume at a time (implemented by `ReadWriteOnce`)

### Deploy
```sh
terraform apply
```

### Clean up

```sh
terraform destroy
```