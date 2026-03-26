resource "aws_security_group" "eks_cluster_additional" {
  name        = "${local.name}-eks-cluster-additional"
  description = "Additional security group for EKS cluster, attached to all nodes"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}-eks-cluster-additional"
  }
}

resource "aws_eks_cluster" "cluster" {
  name = "${local.name}"

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  vpc_config {
		endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = [
      aws_subnet.subnet_1.id,
      aws_subnet.subnet_2.id,
    ]

    security_group_ids = [
      aws_security_group.eks_cluster_additional.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.al2023_worker_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }
}