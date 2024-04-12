### This template demostrate the Pod Identity feature

### Content
- VPC, Subnet, Security Group ... for the EKS cluster
- an EKS cluster (v1.29) and a Managed Node Group
- IAM Role for the pod (`aws_iam_role.pod_role`)
- IAM policy attached to the role and allow listing s3 buckets (`aws_iam_policy.s3_list_buckets_policy`)
- Kubernetes namespace, service account, and sample pod (see [k8s.tf](k8s.tf))
- EKS Pod Identity Association (`aws_eks_pod_identity_association.default`)

### Verify the Pod Identity Setup
A sample pod will be deployed, use the following command to see the output, it should list all the s3 buckets in your account
```sh
kubectl logs pod-identity-pod -n pod-identity-namespace --follow
```

### Deploy
```sh
terraform apply
```

### Clean up

```sh
terraform destroy
```