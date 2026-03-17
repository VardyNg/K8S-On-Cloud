resource "aws_eks_addon" "aws-mountpoint-s3-csi-driver" {

	cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-mountpoint-s3-csi-driver"
  addon_version            = "v2.3.0-eksbuild.1"
	service_account_role_arn = aws_iam_role.s3_role.arn

	depends_on = [
    aws_eks_node_group.default
  ]	
}

resource "aws_s3_bucket" "default" { 
  bucket = "${local.name}-${data.aws_caller_identity.current.account_id}"

  tags = { 
    Name        = "${local.name}-${data.aws_caller_identity.current.account_id}"
  }
}