# Launch Template for Windows node group
resource "aws_launch_template" "windows" {
  name_prefix = "${local.name}-windows-"

  # Make a larger root volume suitable for Windows nodes
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

	 metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = "${local.name}-windows" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.tags, { Name = "${local.name}-windows-root" })
  }
}


# Windows managed node group
resource "aws_eks_node_group" "windows" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "${local.name}-windows"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = module.vpc.private_subnets

  # Use the Windows optimized AMI
  ami_type = "WINDOWS_CORE_2022_x86_64"
  instance_types = ["m5.large"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-windows-node-group"
    }
  )

  # Use the custom launch template for Windows nodes
  launch_template {
    id      = aws_launch_template.windows.id
    version = aws_launch_template.windows.latest_version
  }

  # Ensure that IAM Role permissions and launch template are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_launch_template.windows,
    module.eks
  ]
}
