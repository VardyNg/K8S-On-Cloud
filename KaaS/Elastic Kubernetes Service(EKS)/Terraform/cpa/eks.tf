module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.10.0"

  cluster_name                   = local.name
  cluster_version                = var.eks_version
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]

      amiType      = "AL2_x86_64"
      min_size     = 1
      max_size     = 5
      desired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = local.tags
}