resource "aws_eks_addon" "aws-efs-csi-driver" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-efs-csi-driver"

  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    controller : {
      nodeSelector : {
        some_label = "true"
      }
    }
  })
}