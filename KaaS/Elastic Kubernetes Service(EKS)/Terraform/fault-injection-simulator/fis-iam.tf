resource "aws_iam_role" "fis_role" {
  name = "${local.name}-fis-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "fis.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "fis_policy" {
  name        = "${local.name}-fis-policy"
  description = "Policy for FIS to manage EC2 instances in our EKS node group"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "eks:DescribeNodegroup",
        "ec2:TerminateInstances",
        "ec2:DescribeInstances"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fis_attach" {
  role       = aws_iam_role.fis_role.name
  policy_arn = aws_iam_policy.fis_policy.arn
}

resource "aws_iam_role_policy_attachment" "fis_managed_policy_attach" {
  role       = aws_iam_role.fis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFaultInjectionSimulatorEKSAccess"
}