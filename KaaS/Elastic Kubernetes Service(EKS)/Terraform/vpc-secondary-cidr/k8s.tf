resource "kubernetes_deployment" "nginx" {
	metadata {
		name = "nginx"
		labels = {
			app = "nginx"
		}
	}

	spec {
		replicas = 20

		selector {
			match_labels = {
				app = "nginx"
			}
		}

		template {
			metadata {
				labels = {
					app = "nginx"
				}
			}

			spec {
				container {
					name  = "nginx"
					image = "nginx:latest"

					port {
						container_port = 80
					}
				}
			}
		}
	}
}