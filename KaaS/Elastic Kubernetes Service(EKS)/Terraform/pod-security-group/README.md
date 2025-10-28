## Tesdting Pod Security Group with EKS Cluster

### How to test
- kubectl exec into one of the pods in the Deployment "my-deployment"
- run `curl my-app` to test connectivity to the Service
- provision and deprovision the `aws_security_group_rule.allow_dns_from_pod_sg` and `aws_security_group_rule.allow_dns_tcp_from_pod_sg` resources in to see the effect on DNS resolution from the pod with custom security group.

