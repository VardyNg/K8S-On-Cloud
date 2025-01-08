resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    selector {
      match_labels = {
        run = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          run = "nginx"
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
