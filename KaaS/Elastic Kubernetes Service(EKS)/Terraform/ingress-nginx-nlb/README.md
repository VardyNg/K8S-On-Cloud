# This template demonstrate the use of ingress-nginx with Network Load Balancer (NLB) on AWS EKS cluster using Terraform.

**It is ingress-nginx instead of NGINX Ingress Controller.**

## Architecture

![alt text](doc/image.png)  
NGINX: the ingress-nginx controller

Reference: https://aws.amazon.com/blogs/opensource/network-load-balancer-nginx-ingress-controller-eks/, this doc uses NGINX-Ingress-Controller, but the concept is the same.

## What is included in this template
- A functioning EKS cluster
- Ingress-nginx controller 
- A simple nginx web server Deployment and its Service
- An Ingress that use the ingress-nginx as the Ingress Class
- A Private Hosted zone for testing the Ingress

## How to test
As the NLB URL is dynamic, please manually create a CNAME record in the Private Hosted Zone, setting `test` to the NLB URL. By default, the dommain is `example.com`, therefore, point `test.example.com` to the NLB URL.

Then, in the Cluster VPC, create a bastion host or utilize one of the worker nodes, and try to curl the `test.example.com` domain (assume you're using the default value).
```bash
curl test.example.com
```

you should get a response from the nginx web server.
