resource "aws_eks_node_group" "node-group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "${local.name}-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = [
		aws_subnet.subnet_primary_1.id,
		aws_subnet.subnet_primary_2.id,
		aws_subnet.subnet_primary_3.id,
	]

  scaling_config {
    desired_size = 5
    max_size     = 5
    min_size     = 1
  }
}