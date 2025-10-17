module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.4.0"

  name                   = local.name
  kubernetes_version                = var.eks_version
  endpoint_public_access = true
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  compute_config = {
    enabled = true
    node_pools = [
      "general-purpose"
    ]
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
