# The role that allow "aws-efs-csi-driver"'s IRSA to assume
resource "aws_iam_role" "efs_role" {
  name = "${local.name}-efs_role"

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
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-*",
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "efs_controller" {
  name        = "${local.name}-AWSEFSControllerIAMPolicy"
  path        = "/"
  description = "IAM policy for AWS EFS Controller on EKS"

  policy = file("efs-iam-policy.json")
  # https://aws.amazon.com/blogs/containers/introducing-efs-csi-dynamic-provisioning/
}

resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = aws_iam_role.efs_role.name
  policy_arn = aws_iam_policy.efs_controller.arn
}
