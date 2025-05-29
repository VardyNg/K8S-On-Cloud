resource "aws_eks_node_group" "controller-node-group-2" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "controller-node-group-2"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

	instance_types = ["t3.large"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

	labels = {
		"controller-node" = "true"
	}

	taint {
		key    = "controller-node"
		value  = "true"
		effect = "NO_SCHEDULE"
	}

	tags = var.tags
}