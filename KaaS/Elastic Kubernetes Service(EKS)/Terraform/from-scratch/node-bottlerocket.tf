resource "aws_launch_template" "bottlerocket" {
  name_prefix   = "bottlerocket_eks_node"
  image_id      = "ami-02471ee0da5a34d1e"
  instance_type = "m6i.8xlarge"

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "bottlerocket_eks_node"
    }
  }

  user_data = base64encode(<<-EOT
[settings.kubernetes]
api-server           = "${aws_eks_cluster.cluster.endpoint}"
cluster-certificate  = "${aws_eks_cluster.cluster.certificate_authority[0].data}"
cluster-name         = "${aws_eks_cluster.cluster.name}"
max-pods             = 50

[settings.kubernetes.node-labels]
"role" = "worker"
"os"   = "bottlerocket"

[settings.kubernetes.node-taints]
# e.g. "dedicated" = "bottlerocket:NoSchedule"

[settings.host-containers.admin]
enabled = true

[settings.host-containers.control]
enabled = true

# Optional – you can drop this and let IMDS provide region automatically
[settings.aws]
region = "${local.region}"
EOT
  )
}

resource "aws_eks_node_group" "bottlerocket" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${local.name}-bottlerocket"
  node_role_arn   = aws_iam_role.bottlerocket_worker_node_role.arn

  subnet_ids      = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
  ]

  launch_template {
    id      = aws_launch_template.bottlerocket.id
    version = aws_launch_template.bottlerocket.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
}

resource "aws_iam_role" "bottlerocket_worker_node_role" {
  name = "${local.name}-bottlerocket-worker-node"

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

resource "aws_iam_role_policy_attachment" "bottlerocket_worker_node_role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.bottlerocket_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "bottlerocket_worker_node_role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.bottlerocket_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "bottlerocket_worker_node_role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.bottlerocket_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "bottlerocket_worker_node_role-CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.bottlerocket_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "bottlerocket_worker_node_role-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bottlerocket_worker_node_role.name
}
