module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                   = local.name
  cluster_version                = var.eks_version
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["m5.large"]
      ami_type     = "AL2_x86_64"
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


resource "aws_eks_access_entry" "codebuild" {
  cluster_name      = module.eks.cluster_name
  principal_arn     = aws_iam_role.codebuild.arn
  type              = "STANDARD"
}


resource "aws_eks_access_policy_association" "codebuild" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.codebuild.arn

  access_scope {
    type       = "cluster"
  }
}