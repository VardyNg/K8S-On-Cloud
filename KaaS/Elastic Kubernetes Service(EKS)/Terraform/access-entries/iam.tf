resource "aws_iam_role" "admin_role" {
  name               = "${local.name}-admin-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "describe_eks_policy" {
  name        = "${local.name}-describe-eks"
  path        = "/"
  description = "Policy to allow describe eks"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = [
          module.eks.cluster_arn
        ]
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "admin_role_policy_attachment" {
  name       = "DescribeEKSPolicyAttachment"
  roles      = [aws_iam_role.admin_role.name]
  policy_arn = aws_iam_policy.describe_eks_policy.arn
}
