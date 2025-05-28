
resource "aws_iam_role" "adot_role" {
  name = "${local.name}-adot_role"

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
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:default:adot-collector",
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "adot_xray_writeonly" {
	role       = aws_iam_role.adot_role.name
	policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "adot_cloudwatch_agent" {
	role       = aws_iam_role.adot_role.name
	policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
