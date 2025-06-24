resource "aws_eks_addon" "metrics-server" {
  cluster_name = module.eks.cluster_name
  addon_name   = "metrics-server"

  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name      = "${local.name}-metrics-server"
    Project   = local.name
    ManagedBy = "Terraform"
  }
}
