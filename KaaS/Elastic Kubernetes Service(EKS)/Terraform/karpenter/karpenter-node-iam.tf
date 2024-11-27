resource "aws_iam_role" "karpenter_node_role" {
  name               = "KarpenterNodeRole-${local.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_policy" {
  count     = 4
  role      = aws_iam_role.karpenter_node_role.name
  policy_arn = [
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:${data.aws_partition.current.id}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ][count.index]
}