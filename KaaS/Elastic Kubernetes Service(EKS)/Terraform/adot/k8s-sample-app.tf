resource "kubernetes_service" "sample_app" {
	metadata {
		name = "sample-app"
		labels = {
			"io.kompose.service" = "sample-app"
		}
	}

	spec {
		selector = {
			"io.kompose.service" = "sample-app"
		}

		port {
			name       = "4567"
			port       = 4567
			target_port = 4567
		}
		type = "ClusterIP"
	}
}

resource "kubernetes_deployment" "sample_app" {
	metadata {
		name = "sample-app"
		labels = {
			"io.kompose.service" = "sample-app"
		}
	}

	spec {
		replicas = 1

		selector {
			match_labels = {
				"io.kompose.service" = "sample-app"
			}
		}

		strategy {
			type = "Recreate"
		}

		template {
			metadata {
				labels = {
					"io.kompose.service" = "sample-app"
				}
			}

			spec {
				container {
					name  = "sample-app"
					image = "public.ecr.aws/aws-otel-test/aws-otel-java-spark:1.17.0"

					port {
						container_port = 4567
					}

					env {
						name  = "AWS_REGION"
						value = local.region
					}
					env {
						name  = "LISTEN_ADDRESS"
						value = "0.0.0.0:4567"
					}
					env {
						name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
						value = "http://my-collector-xray-collector:4317"
					}
					env {
						name  = "OTEL_RESOURCE_ATTRIBUTES"
						value = "service.namespace=GettingStarted,service.name=GettingStartedService"
					}
				}

				restart_policy = "Always"
			}
		}
	}
}

