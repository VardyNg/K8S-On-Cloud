# Terraform code to provision AKS cluster

## Prerequisites
- Azure CLI
- Terraform

## Steps to provision AKS cluster
- Login to Azure CLI
  ```sh
  az login
  ```

## Initialize Terraform
- Initialize Terraform
  ```sh
  terraform init
  ```

## Create Terraform plan
- Create Terraform plan
  ```sh
  terraform plan -out "aks.plan"
  ```

## Apply Terraform plan
- Apply Terraform plan
  ```sh
  terraform apply "aks.plan"
  ```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Name of the application | `string` | n/a | yes |
| location | Location of the AKS cluster | `string` | n/a | yes |
| node_vm_size | Size of the node VMs | `string` | n/a | yes |
| node_count | Number of nodes in the cluster | `number` | n/a | yes |