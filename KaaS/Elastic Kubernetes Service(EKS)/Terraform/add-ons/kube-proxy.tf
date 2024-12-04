resource "aws_eks_addon" "kube-proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_update = "OVERWRITE"
}