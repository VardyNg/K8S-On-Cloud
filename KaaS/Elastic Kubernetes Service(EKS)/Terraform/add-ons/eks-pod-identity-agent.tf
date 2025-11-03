resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = module.eks.cluster_name
  addon_name   = "eks-pod-identity-agent"

  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    nodeSelector : {
      some_label = "true"
    }
  })
}