resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${local.name}-default"
  node_role_arn   = aws_iam_role.eks_worker_node.arn
  subnet_ids      = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
  ]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_custom_lt.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_worker_node-AmazonEC2ContainerRegistryReadOnly,
    kubernetes_config_map.aws_auth
  ]
}

resource "aws_launch_template" "eks_custom_lt" {
  name_prefix   = "${local.name}-lt"
  image_id      = data.aws_ssm_parameter.eks_al2023_ami.value
  instance_type = "m5.large"

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
    name: ${aws_eks_cluster.cluster.id}
    apiServerEndpoint: ${aws_eks_cluster.cluster.endpoint}
    certificateAuthority: ${aws_eks_cluster.cluster.certificate_authority.0.data}
    cidr: ${aws_eks_cluster.cluster.kubernetes_network_config.0.service_ipv4_cidr}
--BOUNDARY--
  EOF
  )
}

data "aws_ssm_parameter" "eks_al2023_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}