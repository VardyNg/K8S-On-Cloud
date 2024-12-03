![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
# Kubernetes on Clouds!
This repository contains IaC scripts to deploy Kubernetes Cluster on different Cloud Service Providers!

# Table of Contents
- ✅: Verified
- 🔨: Work in progress
## Kubernetes-as-a-Service (KaaS)
### [Elastic Kubernetes Service (EKS)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/)
#### Authorization and authentication for Pods / Users
- [IAM Roles for Service Accounts (IRSA)](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/irsa/README.md) ✅
- [Pod Identity](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/pod-identity/README.md) ✅
- [Access Entries](/KaaS//Elastic%20Kubernetes%20Service(EKS)/Terraform/access-entries/README.md) ✅

#### Load Balancer and Service 
- [Load Balancer Controller](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/load-balancer/README.md) ✅
- [Cloud Controller Manager](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/cloud-controller-manager/README.md) ✅
- [Ingress Nginx + NLB](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/ingress-nginx-nlb/README.md) ✅

#### Presistent Storage
- [Pod mount EFS Volume](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-efs-volume/README.md) ✅
- [Pod mount EBS Volume](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-ebs-volume/README.md) ✅
- [Pod mount S3 Bucket](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-s3-bucket/README.md) ✅

#### Pod & Node Autoscaling
- [Cluster Proportional Autoscaler (CPA)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/cpa/README.md) 🔨
- [Karpenter](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/karpenter/README.md) ✅
- [Cluster Autosclaer](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/cluster-autoscaler/README.md) 🔨

#### Logging
- [CloudWatch Log: Fluent Bit](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/cloudwatch-log-fluent-bit/README.md) 🔨

#### Node Configuration & Networking
- [Managed Node Group - Custom Launch Template](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/mng-custom-lt/README.md) ✅
- [Cluster Multi-CIDR](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/multi-cidr/README.md) ✅
- [Fully Private Cluster](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/fully-private-cluster/README.md) ✅

#### GPU
- [nivida](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/nivida/README.md) 🔨




#### ![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white) Worker Nodes  
- [windows](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/windows/README.md)



### [Azure Kubernetes Cluster (AKS)](/KaaS/Azure%20Kubernetes%20Service(AKS)/)
- [Terraform](/KaaS/Azure%20Kubernetes%20Service(AKS)/Terraform/README.md)

## Kubeadm
  - v.126
    - [Amazon Web Services(AWS)](/Kubeadm/1.26/AWS)

# How to use this repository
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

# Provision using IaC Tools
- Terraform
  ```sh
  # initalize the terraform
  terraform init

  # create a plan and see what's going to happen and save it to a file
  terraform plan -out plan.out

  # apply the plan
  terraform apply plan.out
  ```


# Contributing
If you want to contribute to this repository, please follow the following steps:
1. Fork the repository
2. Create a new branch
3. Make your changes
4. Create a pull request

  ### Terraform
  The Terraform projects are designed to be isolated and independent, so that you can just copy the whole directory without having to figure out the dependencies between folders in the repo.

  Therefore, there will be duplicated code between examples, this is expected in order to achieve the above goal

  ### CloudFormation
  TBC