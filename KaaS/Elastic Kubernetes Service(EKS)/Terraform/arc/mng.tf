# Launch template for the managed node group
resource "aws_launch_template" "eks_controller_lt" {
  name_prefix   = "${local.name}-controller-lt"
  image_id      = data.aws_ssm_parameter.eks_al2023_ami.value
  instance_type = "t3.medium" # Using t3.medium as minimum size for running Karpenter and ARC

  user_data = base64encode(<<-EOF
Content-Type: multipart/mixed; boundary="BOUNDARY"
MIME-Version: 1.0

--BOUNDARY
Content-Transfer-Encoding: 7bit
Content-Type: application/node.eks.aws
Mime-Version: 1.0

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${module.eks.cluster_name}
    apiServerEndpoint: ${module.eks.cluster_endpoint}
    certificateAuthority: ${module.eks.cluster_certificate_authority_data}
    cidr: ${module.eks.cluster_service_cidr}
  kubelet:
    config:
      # Add labels to identify this node group as controllers
      labels:
        node-role.kubernetes.io/controller: "true"
--BOUNDARY--
  EOF
  )

  # Enable monitoring for the instances
  monitoring {
    enabled = true
  }

  # Enable detailed instance monitoring
  instance_market_options {
    market_type = "spot" # Use spot instances for cost savings
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        "Name"                   = "${local.name}-controller-node"
        "karpenter.sh/discovery" = local.name
      },
      local.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a managed node group for running Karpenter and ARC
resource "aws_eks_node_group" "controller_nodes" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "controller-nodes"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_controller_lt.id
    version = "$Latest"
  }

  # Allow nodes to be drained before destroying
  update_config {
    max_unavailable = 1
  }

  # Set short timeouts for faster deployment
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly_policy,
    aws_iam_role_policy_attachment.eks_ssm_policy
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "${local.name}-controller-node-group"
    }
  )
}