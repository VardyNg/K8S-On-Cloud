resource "kubernetes_deployment" "nginx-fargate" {
  metadata {
    name = "nginx-fargate"
  }

  spec {
    selector {
      match_labels = {
        run = "nginx-fargate"
      }
    }

    template {
      metadata {
        labels = {
          run = "nginx-fargate"
          infrastructure = "fargate"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx"
        }
      }
    }
  }
}