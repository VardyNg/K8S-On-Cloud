module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = "1.31"
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    standard = {
      instance_types = ["m5.large"]

      amiType      = "AL2_x86_64"
      min_size     = 1
      max_size     = 5
      desired_size = 1
    }
    g5-neuron = {
      instance_types = ["g5.xlarge"]

      amiType      = "AL2023_x86_64_NEURON"
      ami_id       = data.aws_ssm_parameter.eks_al2023_ami_neuron.insecure_value
      min_size     = 1
      max_size     = 5
      desired_size = 1
    }
    g5-nvidia = {
      instance_types = ["g5.xlarge"]

      amiType      = "AL2023_x86_64_NVIDIA"
      ami_id       = data.aws_ssm_parameter.eks_al2023_ami_nvidia.insecure_value
      min_size     = 1
      max_size     = 5
      desired_size = 1
    }
  }

  access_entries = {
    # One access entry with a policy associated
    admin = {
      kubernetes_groups = []
      principal_arn     = data.aws_caller_identity.current.arn

      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }

  tags = local.tags
}

data "aws_ssm_parameter" "eks_al2023_ami_neuron" {
  name = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/neuron/recommended/image_id"
}

data "aws_ssm_parameter" "eks_al2023_ami_nvidia" {
  name = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/nvidia/recommended/image_id"
}