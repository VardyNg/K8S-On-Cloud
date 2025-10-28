module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  name                    = local.name
  kubernetes_version      = var.eks_version
  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  access_entries = {
    # Admin access entry
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

	eks_managed_node_groups = {
    default = {
      instance_types = ["m5.large"]

      amiType      = "AL2_x86_64"
      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

	addons = {
		coredns = {
			most_recent = true
		}
		metrics-server = {
			most_recent = true
		}
		kube-proxy = {
			most_recent = true
		}
		vpc-cni = {
			most_recent = true
			configuration_values = jsonencode({
				env = {
					ENABLE_POD_ENI = "true"
					NETWORK_POLICY_ENFORCING_MODE = "strict"
				}
			})
		}
  }

  tags = var.tags
}

# Attach AmazonEKSVPCResourceController policy to the EKS cluster service role
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = module.eks.cluster_iam_role_name
}
