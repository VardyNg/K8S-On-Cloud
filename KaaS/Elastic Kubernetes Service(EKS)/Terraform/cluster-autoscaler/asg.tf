resource "aws_launch_template" "eks_custom_lt" {
  name_prefix   = "${local.name}-lt"
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
    flags:
    - --node-labels=nodeClass=A
--BOUNDARY--
  EOF
  )
}

data "aws_ssm_parameter" "eks_al2023_ami" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

resource "aws_eks_node_group" "mng-custom" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "mng-custom-2"
  node_role_arn   = aws_iam_role.eks_worker_role.arn

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.eks_custom_lt.id
    version = "$Latest"
  }

	tags = {
		"k8s.io/cluster-autoscaler/enabled" = "true"
		"k8s.io/cluster-autoscaler/${module.eks.cluster_name}" = "owned"
	}
}