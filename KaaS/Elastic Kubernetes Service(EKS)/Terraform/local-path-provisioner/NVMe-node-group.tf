resource "aws_launch_template" "controller_custom_lt" {
  name_prefix   = "${local.name}-nvme-lt"
  image_id      = data.aws_ssm_parameter.eks_al2023_ami.value
  instance_type = "c6id.4xlarge"

  user_data = base64encode(templatefile("${path.module}/user-data.tpl", {
    cluster_name         = module.eks.cluster_name
    cluster_endpoint     = module.eks.cluster_endpoint
    cluster_ca           = module.eks.cluster_certificate_authority_data
    cluster_service_cidr = module.eks.cluster_service_cidr
    setup_script         = file("${path.module}/setup-raid.sh")
  }))

	tags = var.tags
}

resource "aws_eks_node_group" "nvme-node-group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "nvme-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.controller_custom_lt.id
    version = "$Latest"
  }

	labels = {
		"controller-node" = "true"
	}

	tags = var.tags
}
