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

# Define the IAM role
resource "aws_iam_role" "eks_s3_list_buckets_role" {
  name               = "EKS_S3_List_Buckets_Role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:${kubernetes_namespace_v1.ns.metadata.0.name}:${local.name}-sa",
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
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
