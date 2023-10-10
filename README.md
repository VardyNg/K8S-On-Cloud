# Kubernetes on Clouds!
This repository contains IaC scripts for deploying Kubernetes cluster on different Cloud Service Provider!

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
