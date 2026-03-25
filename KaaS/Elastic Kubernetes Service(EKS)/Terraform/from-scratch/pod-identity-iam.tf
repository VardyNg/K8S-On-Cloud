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


resource "aws_iam_policy" "s3_list_buckets_policy_pod_identity" {
  name        = "S3ListBucketsPolicy-pod-identity"
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
resource "aws_iam_policy_attachment" "s3_list_buckets_policy_attachment_pod_identity" {
  name       = "S3ListBucketsPolicyAttachment"
  roles      = [aws_iam_role.pod_role.name]
  policy_arn = aws_iam_policy.s3_list_buckets_policy_pod_identity.arn
}

resource "aws_eks_pod_identity_association" "default" {
  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = kubernetes_namespace_v1.pod-identity.metadata.0.name
  service_account = kubernetes_service_account.pod-identity-sa.metadata.0.name
  role_arn        = aws_iam_role.pod_role.arn
}
