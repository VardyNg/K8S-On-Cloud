# The role for Pod to use
resource "aws_iam_role" "pod_role" {
  name = "pod_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_policy" "s3_list_buckets_policy" {
  name        = "S3ListBucketsPolicy"
  description = "Allows listing buckets in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:ListAllMyBuckets"]
      Resource = "*"
    }]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "s3_list_buckets_policy_attachment" {
  name       = "S3ListBucketsPolicyAttachment"
  roles      = [aws_iam_role.pod_role.name]
  policy_arn = aws_iam_policy.s3_list_buckets_policy.arn
}

resource "aws_eks_pod_identity_association" "default" {
  cluster_name    = module.eks.cluster_name
  namespace       = kubernetes_namespace_v1.ns.metadata.0.name
  service_account = kubernetes_service_account.sa.metadata.0.name
  role_arn        = aws_iam_role.pod_role.arn
}
