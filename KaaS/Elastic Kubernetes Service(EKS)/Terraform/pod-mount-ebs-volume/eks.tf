module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name                   = local.name
  cluster_version                = "1.29"
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

  manage_aws_auth_configmap = true

  cluster_addons = {
    aws-ebs-csi-driver ={
      most_recent = true
      service_account_role_arn = aws_iam_role.ebs_role.arn
    }
  }

  tags = local.tags
}
