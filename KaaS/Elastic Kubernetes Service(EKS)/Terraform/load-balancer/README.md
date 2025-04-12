### Deploy a sample NGINX Deployment with Application Load Balancer
#### Aims:
##### Test out the Load Balancer Controller and Ingress annotation deploying Application Load Balancer.
---
#### Content
- Load Balancer Controller **(LBC)** and necessary IAM Roles
- EKS cluster
- K8s NGINX Deployment and Service
- Certs for domain hosted in ACM
- <b>Application Load Balancer (ALB)</b>
  - Multiple Ingress, same IngressGroup
    - `kubernetes_ingress_v1.nginx-1`
    - `kubernetes_ingress_v1.nginx-2` 
  - Signle Ingress, multiple Rule
    - `kubernetes_ingress_v1.alb-by-ingress`
- <b>Network Load Balancer</b>
  - Created by A Service of type LoadBalancer
    - `kubernetes_service_v1.nlb-by-service`
  - Use TargetGroup Binding to bind a service to a NLB
    - [nlb-target-group-binding.tf](nlb-target-group-binding.tf)
    
---

#### View outputs
- `configure_kubectl`: command to configure kubectl
- `nlb-by-service-dns-name`: DNS name of the NLB created by a service of type LoadBalancer
- `nlb-with-target-group-dns-name`: DNS name of the NLB with TargetGroupBinding
- `alb-by-ingress-dns-name`: DNS name of the ALB created by Ingress
- `alb-with-group-dns-name`: DNS name of the ALB created with ingress group