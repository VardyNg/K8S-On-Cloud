resource "aws_eks_addon" "amazon-cloudwatch-observability" {
	cluster_name = aws_eks_cluster.cluster.name
	addon_name = "amazon-cloudwatch-observability"
	addon_version = "v5.2.2-eksbuild.1"
	configuration_values = jsonencode({
		containerLogs = {
			enabled = true
			fluentBit = {
				config = {
					service       = file("${path.module}/fluentbit/fluent-bit-service.conf")
					customParsers = file("${path.module}/fluentbit/fluent-bit-parsers.conf")
					extraFiles = {
						"application-log.conf" = file("${path.module}/fluentbit/application-log.conf")
						"dataplane-log.conf"   = file("${path.module}/fluentbit/dataplane-log.conf")
						"host-log.conf"        = file("${path.module}/fluentbit/host-log.conf")
					}
				}
			}
		}
	})

	service_account_role_arn = aws_iam_role.cloudwatch_role.arn

	depends_on = [
		aws_eks_cluster.cluster
	]
}