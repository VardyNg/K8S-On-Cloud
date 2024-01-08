# Terraform code to provision EKS cluster

## Prerequisites
- AWS CLI
- Terraform

## Steps to provision EKS cluster
- Login to AWS CLI
  ```sh
  aws configure
  ```

## Deploy Terraform
- Initialize Terraform
  ```sh
  terraform init
  ```
- Create Terraform plan
  ```sh
  terraform plan -out "aks.plan"
  ```

- Apply Terraform plan
  ```sh
  terraform apply "aks.plan"
  ```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the EKS cluster | `string` | `""` | yes |
| subnet_az_list | List of AZs to create subnets in | `list(string)` | `[]` | yes |