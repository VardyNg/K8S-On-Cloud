data "aws_iam_policy_document" "ascp_assume_role" {
	statement {
		actions = ["sts:AssumeRoleWithWebIdentity"]
		effect  = "Allow"
		principals {
			type        = "Federated"
			identifiers = [module.eks.oidc_provider_arn]
		}
		condition {
			test     = "StringEquals"
			variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
			values   = ["system:serviceaccount:${kubernetes_namespace.example.metadata[0].name}:${local.deployment_sa}"]
		}
	}
}

resource "aws_iam_policy" "ascp" {
	name        = "ASCPSecretsManagerPolicy"
	description = "Policy for ASCP to access AWS Secrets Manager"
	policy      = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"secretsmanager:GetSecretValue",
				"secretsmanager:DescribeSecret"
			],
			"Resource": "*"
		}
	]
}
EOF
}

resource "aws_iam_role" "ascp_irsa" {
	name               = "ascp-irsa-role"
	assume_role_policy = data.aws_iam_policy_document.ascp_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ascp_attach" {
	role       = aws_iam_role.ascp_irsa.name
	policy_arn = aws_iam_policy.ascp.arn
}