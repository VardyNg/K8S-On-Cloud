resource "aws_iam_policy" "s3_list_buckets_policy" {
  name        = "${local.name}-s3-list-buckets-policy"
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

# Define the IAM role
resource "aws_iam_role" "eks_s3_list_buckets_role" {
  name               = "${local.name}-eks-s3-list-buckets-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.cluster_oidc}"
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.cluster_oidc}:sub": "system:serviceaccount:${kubernetes_namespace_v1.irsa.metadata.0.name}:irsa-test-sa",
          "${local.cluster_oidc}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "s3_list_buckets_policy_attachment" {
  name       = "S3ListBucketsPolicyAttachment"
  roles      = [aws_iam_role.eks_s3_list_buckets_role.name]
  policy_arn = aws_iam_policy.s3_list_buckets_policy.arn
}
