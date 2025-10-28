resource "kubernetes_namespace" "default" {
	metadata {
		name = local.name
	}
}

resource "kubernetes_deployment" "my_deployment" {
	metadata {
		name      = "my-deployment"
		namespace = kubernetes_namespace.default.metadata[0].name
		labels = {
			app = "my-app"
		}
	}

	spec {
		replicas = 4

		selector {
			match_labels = {
				app = "my-app"
			}
		}

		template {
			metadata {
				labels = {
					app  = "my-app"
					role = "my-role"
				}
			}

			spec {
				termination_grace_period_seconds = 120

				container {
					name  = "nginx"
					image = "public.ecr.aws/nginx/nginx:1.23"

					port {
						container_port = 80
					}
				}
			}
		}
	}
}

resource "kubernetes_service" "my_app" {
	metadata {
		name      = "my-app"
		namespace = kubernetes_namespace.default.metadata[0].name
		labels = {
			app = "my-app"
		}
	}

	spec {
		selector = {
			app = "my-app"
		}

		port {
			protocol    = "TCP"
			port        = 80
			target_port = 80
		}
	}
}