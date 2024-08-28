resource "aws_iam_role" "s3_role" {
  name = "${local.name}-s3_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:s3-csi-*",
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_controller_attachement" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name        = "${local.name}-policy"

  policy = data.template_file.s3_policy.rendered
}

data "template_file" "s3_policy" {
  template = file("${path.module}/s3-iam-policy.tftpl")

  vars = {
    bucket_name = aws_s3_bucket.default.id
  }
}
