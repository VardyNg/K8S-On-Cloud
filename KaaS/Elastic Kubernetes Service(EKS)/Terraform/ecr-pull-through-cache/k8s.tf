resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

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
          image = "${data.aws_caller_identity.current.id}.dkr.ecr.${var.region}.amazonaws.com/ecr-public/nginx/nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
