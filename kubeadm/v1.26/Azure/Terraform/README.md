![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
## Kubernetes on Azure Virtual Machines with Terraform and Kubeadm

This repository contains Terraform code to deploy a Kubernetes cluster on Azure Virtual Machines using Kubeadm.

## Prerequisites
- Terraform
- Azure CLI

## Usage
1. Clone this repository
2. Create a `terraform.tfvars` file and fill in the required variables
3. Run `terraform init`
4. Run `terraform apply`


## Variables
| Variable Name       | Description                                                      | Type   | Default Value |
|---------------------|------------------------------------------------------------------|--------|---------------|
| app_name            | The name of the application                                      | string | -             |
| location            | The Azure Region in which all resources in this example should be created. | string | -             |
| node_count          | The number of nodes to create in the cluster                    | number | -             |
| location_max_az     | The maximum availability zone index in the location             | number | 3             |
| vm_admin_username   | Value of the admin username for the VMs            | string | -             |
| vm_admin_password   | Value of the admin password for the VMs            | string | -             |

You should set the following variable from the command line:
```sh
export TF_VAR_vm_admin_username=<username>
export TF_VAR_vm_admin_password=<password>
```

## Outputs
| Output Name         | Description                                                      | Type   |
|---------------------|------------------------------------------------------------------|--------|
| vm_public_ips       | The public IP addresses of the VMs                               | list   |
## Provisioned Resources
- Azure VNet
- Azure Subnet
- Azure Network Security Group
- Azure Network Interface Cards (NIC) x 3
- Azure Virtual Machines (VM) x 3
- Azure Public IP Addresses x 3

## Connect to the Virtual Machines
***This is NOT production ready, you should configure a more secure way for connection, like using SSH Key or Bastion host. This is indented for demo only!***

```sh
ssh <username>@<public_ip> 
# then input the password
```

