resource "aws_security_group" "eks_self_managed_sg" {
  name        = "${local.name}-eks_self_managed_sg"
  description = "security group for self managed nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups = aws_eks_cluster.cluster.vpc_config.0.security_group_ids
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpc_endpoints.id]
  }

  tags = {
    Name = "${local.name}-eks_self_managed_sg"
  }
}


resource "aws_launch_template" "eks_self_managed_lt" {
  name_prefix   = "${local.name}-self-managed-lt"
  image_id      = data.aws_ssm_parameter.eks_al2023_ami.value
  instance_type = "m5.large"
	vpc_security_group_ids = [ aws_security_group.eks_self_managed_sg.id ]
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

	iam_instance_profile {
    name = aws_iam_instance_profile.self_managed_profile.name
  }
}


resource "aws_autoscaling_group" "eks_self_managed_ng" {
  name_prefix          = "${local.name}-self-managed-lt"

  launch_template {
    id      = aws_launch_template.eks_self_managed_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = [
		aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
	]

  min_size            = 1
  max_size            = 10
  desired_capacity    = 1

  tag {
    key                 = "Name"
    value               = "${local.name}-self-managed-node"
    propagate_at_launch = true
  }
}

resource "aws_iam_instance_profile" "self_managed_profile" {
  name = "${local.name}-self_managed_profile"
  role = aws_iam_role.self_managed_worker_node_role.name
}

resource "aws_iam_role" "self_managed_worker_node_role" {
  name = "${local.name}-self_managed-worker-node"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "self_managed_worker_node_role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.self_managed_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "self_managed_worker_node_role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.self_managed_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "self_managed_worker_node_role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.self_managed_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "self_managed_worker_node_role-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.self_managed_worker_node_role.name
}
