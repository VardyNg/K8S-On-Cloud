module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  name                    = local.name
  kubernetes_version      = var.eks_version
  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa         = true
  authentication_mode = "CONFIG_MAP"

	eks_managed_node_groups = {
    linux = {
      instance_types = ["m5.large"]

      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
  }

  addons = {
    coredns = {
      most_recent    = true
      before_compute = true
    }
    metrics-server = {
      most_recent    = true
      before_compute = true
    }
    kube-proxy = {
      most_recent    = true
      before_compute = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  tags = var.tags
}

# Get the latest Amazon Linux 2023 AMI for EKS
data "aws_ssm_parameter" "eks_al2023_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

