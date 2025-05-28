resource "aws_eks_addon" "adot" {
  cluster_name = module.eks.cluster_name
  addon_name   = "adot"

  resolve_conflicts_on_update = "OVERWRITE"

	service_account_role_arn = aws_iam_role.adot_role.arn

  configuration_values = jsonencode({

  })

	// THE ADOT add-on requires the cert-manager to be installed first.
	depends_on = [ helm_release.cert_manager ]
}