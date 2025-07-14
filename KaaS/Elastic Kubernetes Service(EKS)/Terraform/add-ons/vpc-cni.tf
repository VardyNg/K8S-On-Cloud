
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name      = "${local.name}-vpc-cni"
    Project   = local.name
    ManagedBy = "Terraform"
  }
}
