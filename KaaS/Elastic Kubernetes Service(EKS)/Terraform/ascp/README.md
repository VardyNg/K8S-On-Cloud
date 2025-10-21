# Using AWS Secret Controller for Secrets and Configuration Provider (ASCP) with EKS and Terraform

## Overview
- A Helm installation that install ASCP
- A `SecretProviderClass` that defines the AWS Secrets Manager secret to be accessed
- A Kubernetes deployment that uses the ASCP to mount the secret as a volume
- A Service Account with IRSA to allow the pod to access the secret