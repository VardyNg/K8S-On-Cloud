resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "eks-pod-identity-agent"

  depends_on = [
    aws_eks_node_group.default
  ]
}
