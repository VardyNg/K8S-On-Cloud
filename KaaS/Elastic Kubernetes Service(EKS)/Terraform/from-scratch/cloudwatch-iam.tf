
resource "aws_iam_role" "cloudwatch_role" {
  name = "${local.name}-cloudwatch_role"
	
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
          "${local.cluster_oidc}:sub": "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent",
          "${local.cluster_oidc}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "cw_controller_attach" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cw_node_attach" {
  role       = aws_iam_role.eks_worker_node.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}