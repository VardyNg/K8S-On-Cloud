# General
project_name = "k8s-kubeadm-1.2.6"
# VPC
vpc_cidr            = "10.0.0.0/16"
vpc_azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_private_subnets = []
vpc_public_subnets  = ["10.0.101.0/24"]
# EC2
ami           = "ami-0fd2c44049dd805b8" # Ubuntu 22.04 LTS amd64 20230303
instance_type = "t3.medium"
key_name      = "key"