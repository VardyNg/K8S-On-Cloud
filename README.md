![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
# Kubernetes on Clouds!
This repository contains IaC scripts for deploying Kubernetes cluster on different Cloud Service Provider!

## Table of Contents
- Kubernetes-as-a-Service (KaaS)
  - [Azure Kubernetes Cluster (AKS)](/KaaS/Azure%20Kubernetes%20Service(AKS)/)
    - [Terraform](/KaaS/Azure%20Kubernetes%20Service(AKS)/Terraform/README.md)
  - [Elastic Kubernetes Service (EKS)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/)
    - [CloudFormation](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/CloudFormation/README.md)
    - Terraform
      - [Pod IAM Permissions](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/pod-iam-permission/README.md)
      - [Load Balancer](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/load-balancer/README.md)
      - [Pod Identity](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/pod-identity/README.md)
      - [Pod mount EFS Volume](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-efs-volume/README.md)
      - [Pod mount EBS Volume](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-ebs-volume/README.md)
- Kubeadm
  - v.126
    - [Amazon Web Services(AWS)](/Kubeadm/1.26/AWS)

## How to use this repository
This repository is organized in a way that you can easily find the script that you need. The folder structure is as follows:

```
├── README.md
├── [Kubernetes distro / installer]
│   ├── [Kubernetes version]
│   │   │  ├── [Cloud Service Provider]
│   │   │  │   ├── [IaC tool]
├── KaaS (Kubernetes as a Service)
│   ├── [Cloud Service Provider's KaaS]
│   │   ├── [IaC Script]

```
Clone the project, run the script and you are good to go!

#### Provision using IaC Tools
- Terraform
  ```sh
  terraform init # initalize the terraform
  terraform plan -out plan.out # create a plan and see what's going to happen and save it to a file
  terraform apply plan.out # apply the plan
  ```


#### Contributing
If you want to contribute to this repository, please follow the following steps:
1. Fork the repository
2. Create a new branch
3. Make your changes
4. Create a pull request
