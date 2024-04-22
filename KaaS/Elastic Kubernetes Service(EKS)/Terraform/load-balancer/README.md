### Deploy a sample NGINX Deployment with Application Load Balancer
#### Aims:
##### Test out the Load Balancer Controller and Ingress annotation deploying Application Load Balancer.
---
#### Content
- Load Balancer Controller **(LBC)** (v2.7.2) and necessary IAM Roles
- EKS cluster v1.29
- K8s NGINX Deployment and Service
- Certs for domain hosted in ACM
- Ingresses that will deploy TWO Application Load Balancer (ALB) via Ingress annotations observed by the LBC
  - Multiple Ingress, same IngressGroup
    - `kubernetes_ingress_v1.nginx-1`
    - `kubernetes_ingress_v1.nginx-2` 
  - Signle Ingress, multiple Rule
    - `kubernetes_ingress_v1.nginx-3`
---
