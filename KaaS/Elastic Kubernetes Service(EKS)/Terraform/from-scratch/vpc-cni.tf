resource "aws_eks_addon" "vpc-cni" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "vpc-cni"
  addon_version            = "v1.21.1-eksbuild.3"

	configuration_values =  jsonencode({
		enableWindowsIpam = "true"
	})
}