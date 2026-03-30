resource "aws_launch_template" "ca_eks_node_lt" {
  name_prefix   = "${local.name}-ca"
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
    name: ${aws_eks_cluster.cluster.id}
    apiServerEndpoint: ${aws_eks_cluster.cluster.endpoint}
    certificateAuthority: ${aws_eks_cluster.cluster.certificate_authority.0.data}
    cidr: ${aws_eks_cluster.cluster.kubernetes_network_config.0.service_ipv4_cidr}
  kubelet:
    flags:
    - --node-labels=nodeClass=A
--BOUNDARY--
  EOF
  )
}

resource "aws_eks_node_group" "ca-ng" {
  cluster_name    = aws_eks_cluster.cluster.id
  node_group_name = "ca-ng"
  node_role_arn   = aws_iam_role.ca_eks_worker_role.arn

  subnet_ids      = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
  ]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.ca_eks_node_lt.id
    version = "$Latest"
  }

	tags = {
		"k8s.io/cluster-autoscaler/enabled" = "true"
		"k8s.io/cluster-autoscaler/${aws_eks_cluster.cluster.id}" = "owned"
	}
}