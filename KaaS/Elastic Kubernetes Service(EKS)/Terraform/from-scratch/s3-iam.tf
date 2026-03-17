resource "aws_iam_role" "s3_role" {
  name = "${local.name}-s3_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.cluster_oidc}"
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "${local.cluster_oidc}:sub": "system:serviceaccount:kube-system:s3-csi-*",
          "${local.cluster_oidc}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_controller_attachement" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

resource "aws_iam_policy" "s3-policy" {
  name = "${local.name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MountpointFullBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.default.id}"
        ]
      },
      {
        Sid    = "MountpointFullObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.default.id}/*"
        ]
      }
    ]
  })
}
