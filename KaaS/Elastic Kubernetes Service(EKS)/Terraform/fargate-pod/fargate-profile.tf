
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "default"
    labels = {
      infrastructure = "fargate"
    }
  }
}

resource "aws_iam_role" "fargate" {
  name = "${local.name}-fargate-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}