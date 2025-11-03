module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  name                    = local.name
  kubernetes_version      = var.eks_version
  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    test = {
      instance_types = ["m5.large"]

      amiType      = "AL2_x86_64"
      min_size     = 1
      max_size     = 5
      desired_size = 2

    },
    some_node_group = {
      instance_types = ["m5.large"]

      amiType      = "AL2_x86_64"
      min_size     = 1
      max_size     = 5
      desired_size = 2

      labels = {
        some_label = "true"
      }
    }
  }

  # Additional security group rules for worker nodes
  node_security_group_additional_rules = {
    # Allow port 10251 traffic from the cluster security group (metric server)
    ingress_10251_self = {
      description                   = "Allow metric server access from cluster security group"
      protocol                      = "tcp"
      from_port                     = 10251
      to_port                       = 10251
      type                          = "ingress"
      source_cluster_security_group = true
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

  tags = local.tags
}
