resource "kubernetes_service" "traffic_generator" {
	metadata {
		name = "traffic-generator"
		labels = {
			"io.kompose.service" = "traffic-generator"
		}
	}

	spec {
		selector = {
			"io.kompose.service" = "traffic-generator"
		}

		port {
			name        = "80"
			port        = 80
			target_port = 80
		}

		type = "ClusterIP"
	}
}

resource "kubernetes_deployment" "traffic_generator" {
	metadata {
		name = "traffic-generator"
		labels = {
			"io.kompose.service" = "traffic-generator"
		}
	}

	spec {
		replicas = 1

		selector {
			match_labels = {
				"io.kompose.service" = "traffic-generator"
			}
		}

		template {
			metadata {
				labels = {
					"io.kompose.service" = "traffic-generator"
				}
			}

			spec {
				container {
					name  = "traffic-generator"
					image = "ellerbrock/alpine-bash-curl-ssl:latest"

					args = [
						"/bin/bash",
						"-c",
						"sleep 10; while :; do curl sample-app:4567/outgoing-http-call > /dev/null 1>&1; sleep 2; curl sample-app:4567/aws-sdk-call > /dev/null 2>&1; sleep 5; done"
					]

					port {
						container_port = 80
					}
				}

				restart_policy = "Always"
			}
		}
	}
}