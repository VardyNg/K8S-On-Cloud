### This template demostrate the use of Cloud Controller Manager to provision NLB and CLB in EKS

### Content
- VPC, Subnet, Security Group ... for the EKS cluster
- an EKS cluster (v1.29) and a Managed Node Group
- Kubernetes namespace, deployment, and 2 services for NLB and CLB


### Verify the set up
- K8s Services should yield something like
```sh
kubectl get svc -n default 

NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP                                                                        PORT(S)        AGE
cloud-controller-manager-clb   LoadBalancer   172.20.3.15     a6fa31c964f5f4ba8abb963d8b297a54-259685839.ca-central-1.elb.amazonaws.com          80:30598/TCP   125m
cloud-controller-manager-nlb   LoadBalancer   172.20.108.52   ab9ae4d7f72234571af3517217652bd0-b6d1c1e3298914c0.elb.ca-central-1.amazonaws.com   80:30498/TCP   125m
```

- There should be 2 load balancers created in the account
  - a Classic Load Balancer
  - a Network Load Balancer

### Deploy
```sh
terraform apply
```

### Clean up

```sh
terraform destroy
```