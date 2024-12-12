## This template demostrate the implementation of a ECR Pull Through Cache with EKS

Configure a private ECR registry to cache ECR Public Images

In this example, a Deployment with image `123456789.dkr.ecr.<region>.amazonaws.com/ecr-public/nginx/nginx:latest` will be deployed. It is eseentially pulling from https://gallery.ecr.aws/nginx/nginx. As the image include `ecr-public`, it hits the Pull Through Cache Rule and utilize the Pull Through Cache.

## Reference
- https://aws-ia.github.io/terraform-aws-eks-blueprints/patterns/ecr-pull-through-cache/