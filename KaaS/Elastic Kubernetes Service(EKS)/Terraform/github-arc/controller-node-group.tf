resource "aws_launch_template" "controller_custom_lt" {
  name_prefix   = "${local.name}-controller-lt"
  image_id      = data.aws_ssm_parameter.eks_al2023_ami.value
  instance_type = "t3.medium"

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
      registerWithTaints:
      - key: controller-node
        value: "true"
        effect: NoSchedule
--BOUNDARY--
  EOF
  )

	tags = var.tags
}

resource "aws_eks_node_group" "controller-node-group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "controller-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 1
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
