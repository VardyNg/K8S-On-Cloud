![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
# Kubernetes on Clouds!
This repository contains IaC scripts to deploy Kubernetes Cluster on different Cloud Service Providers!

# Table of Contents
- ✅: Verified
- 🔨: Work in progress
## Kubernetes-as-a-Service (KaaS)
### [Elastic Kubernetes Service (EKS)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/)

### Architecture
- [From Scratch](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/from-scratch/README.md) ✅  
  Deploy EKS Cluster without using Terraform Module

### Authorization and authentication for Pods / Users
- [IAM Roles for Service Accounts (IRSA)](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/irsa/README.md) ✅  
  Assign IAM Roles to Pods via Kubernetes Service Account
- [Pod Identity](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/pod-identity/README.md) ✅  
  Assign IAM Roles to Pods via EKS Pod Identity Association
- [Access Entries](/KaaS//Elastic%20Kubernetes%20Service(EKS)/Terraform/access-entries/README.md) ✅  
  Grant cluster access right to IAM User/Role via Access Entries

### Load Balancer and Service 
- [Load Balancer Controller](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/load-balancer/README.md) ✅  
  Create ALB via Ingress, NLB via Service, and use TargetGroupBinding with Load Balancer Controller (LBC)
- [Cloud Controller Manager](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/cloud-controller-manager/README.md) ✅  
  Create CLB via LoadBalancer type Service using Cloud Controller Manager (CCM)
- [Ingress Nginx + NLB](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/ingress-nginx-nlb/README.md) ✅  
  Use Ingress Controller (ingress-ngix) with NLB
- [NGINX Ingress + NLB](/KaaS/Elastic%20Kubernetes%20Service%28EKS%29/Terraform/nginx-ingress-nlb/README.md) ✅  
  Use Ingress Controller (NGINX Ingress) with NLB

### Presistent Storage
- [Pod mount EFS Volume](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-efs-volume/README.md) ✅  
  Mount EFS Volume to Pod
- [Pod mount EBS Volume](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-ebs-volume/README.md) ✅  
  Mount EBS Volume to Pod
- [Pod mount S3 Bucket](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-mount-s3-bucket/README.md) ✅  
  Mount S3 Bucket to Pod
- [Logical Volume Manager (LVM)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/csi-driver-lvm/README.md) ✅  
  Use LVM to create a volume and mount it to Pod
### Pod & Node Autoscaling
- [Cluster Proportional Autoscaler (CPA)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/cpa/README.md)  ✅  
  Scale pods based on the number of nodes/cores in cluster
- [Horizontal Pod Autoscaler (HPA)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/horizontal-pod-autoscaler/README.md) ✅  
  Scale deployment based on CPU and Memory usage, by adjusting the replicas in Deployment/ReplicaSet/StatefulSet...
- [Vertical Pod Autoscaler (VPA)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/vertical-pod-autoscaler/README.md) ✅  
  Adjust the resource requests of the pods based on the observed utilization of the pods

  
- [Karpenter](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/karpenter/README.md) ✅  
  Scale nodes based on pod requirements
- [Cluster Autosclaer](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/cluster-autoscaler/README.md) ✅
  Scale nodes based on pod requirements
- [Fargate Pod](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/fargate-pod/README.md) ✅  
  Run pods on Fargate
### Logging
- [CloudWatch Log: Fluent Bit](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/cloudwatch-log-fluent-bit/README.md) 🔨  
  Emit logs to CloudWatch Log using Fluent Bit
- [Amazon Distro for OpenTelemetry (ADOT)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/adot/README.md) ✅  
	Use ADOT to collect logs and metrics from EKS Cluster
### Node Configuration & Networking
- [Managed Node Group - Custom Launch Template](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/mng-custom-lt/README.md) ✅  
  Supply custom launch template to Managed Node Group  
- [Kubelet Resource Reservation](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/kubelet-resource-reservation/README.md) ✅  
  Configure kubelet and system OS resource reservation for improved cluster stability
- [VPC Secondary CIDR](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/vpc-secondary-cidr/README.md) ✅  
  Configure EKS cluster to also use the secondary CIDR block of the VPC
- [Fully Private Cluster](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/fully-private-cluster/README.md) ✅  
  Create a fully private EKS cluster
- [Customize Cluster DNS Domain](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/custom-cluster-domain/README.md) ✅  
  Customize the DNS domain for the EKS cluster
- [Security Groups for Pods](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/pod-security-group/README.md) ✅  
	Assign Security Groups to Pods
### GPU
- [nivida](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/nivida/README.md) 🔨  
  Provision GPU nodes


### ![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white) Worker Nodes  
- [windows](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/windows/README.md) ✅  
  Use Windows Worker Nodes in EKS

### Workload
- [add-ons (Advanced Configurations)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/add-ons/README.md)   
  Use Advanced Configurations in EKS Add-On
- [add-ons (Pod Identity)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/EKSCTL/Add-On-Pod-Identity/README.md) ✅  
  Use Pod Identity in Add-ons instaed of IRSA

### Docker Images
- [ECR Pull Through Cache](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/ecr-pull-through-cache/README.md) ✅  
  Use ECR as Pull Through Cache in EKS Cluster

### EKS Auto Mode
- [EKS Auto Mode](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/eks-auto-mode/README.md) ✅  
  Use EKS Auto Mode to manage node groups, pods, and services, and so on.

### Cost Management
- [Kubecost](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/kubecost/README.md) ✅  
  Deploy Kubecost in EKS Cluster

### AWS Integration
- [AWS Batch](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/aws-batch/README.md) ✅  
  Use EKS to run AWS Batch Jobs
- [AWS CodeBuild](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/codebuild-interactions/README.md) ✅  
  Execute kubectl commands in EKS Cluster using AWS CodeBuild
- [AWS Resilience Hub](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/fault-injection-simulator/README.md) ✅  
  Use AWS Resilience Hub - Fault Injection Service in EKS Cluster
- [AWS Secret Controller for Secrets and Configuration Provider (ASCP)](/KaaS/Elastic%20Kubernetes%20Service(EKS)/Terraform/ascp/README.md) ✅  
	Use ASCP to mount Secrets Manager secret to Pod as file or environment variable

### Tools to deploy EKS
- [AWS CDK](/KaaS/Elastic%20Kubernetes%20Service(EKS)/CDK/simple/README.md) ✅  
  Use AWS CDK to deploy a simple EKS Cluster
- [AWS CloudFormation](/KaaS/Elastic%20Kubernetes%20Service(EKS)/CloudFormation/README.md) ✅  
  Use AWS CloudFormation to deploy a simple EKS Cluster
- [EKSCTL](/KaaS/Elastic%20Kubernetes%20Service(EKS)/EKSCTL/Add-On-Pod-Identity/README.md) ✅  
  Use EKSCTL to configure an EKS cluster, with Add-on Pod Identity

### [Azure Kubernetes Cluster (AKS)](/KaaS/Azure%20Kubernetes%20Service(AKS)/) 🔨
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