resource "kubernetes_service_account" "adot_collector" {
	metadata {
		name      = "adot-collector"
		namespace = "default"
		annotations = {
			"eks.amazonaws.com/role-arn" = aws_iam_role.adot_role.arn
		}
	}
}

