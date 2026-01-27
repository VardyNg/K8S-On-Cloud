module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name                   = local.name
  kubernetes_version     = var.eks_version
  endpoint_public_access = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    linux = {
      instance_types = ["m5.large"]

      ami_type     = "AL2023_x86_64_STANDARD"
      min_size     = 1
      max_size     = 5
      desired_size = 2
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
            type = "cluster"
          }
        }
      }
    }
  }

  addons = {
    vpc-cni = {
      most_recent = true
			before_compute = true
      resolve_conflicts_on_update = "OVERWRITE"
      # https://github.com/aws/amazon-vpc-cni-k8s/issues/2726#issuecomment-1869078906
      configuration_values =  jsonencode({
        enableWindowsIpam = "true"
      })
    }

		coredns = {
			most_recent = true
			before_compute = true
			resolve_conflicts_on_update = "OVERWRITE"
		}

		kube-proxy = {
			most_recent = true
			before_compute = true
			resolve_conflicts_on_update = "OVERWRITE"
		}
  }
  tags = local.tags
}

