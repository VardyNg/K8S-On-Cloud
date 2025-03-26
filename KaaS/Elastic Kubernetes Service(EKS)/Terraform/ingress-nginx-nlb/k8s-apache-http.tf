resource "kubernetes_namespace" "sample-app-apache" {
  metadata {
    name = "sample-app-apache"
  }
}

resource "kubernetes_deployment" "apache" {
  metadata {
    name = "apache-deployment"
    labels = {
      app = "apache"
    }
  }

  spec {
    replicas = 5
    selector {
      match_labels = {
        app = "apache"
      }
    }

    template {
      metadata {
        labels = {
          app = "apache"
        }
      }

      spec {
        container {
          image = "httpd:latest"
          name  = "apache"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "apache" {
  metadata {
    name = "apache-service"
  }
  
  spec {
    selector = {
      app = "apache"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "apache" {
  metadata {
    name = "apache-ingress"

    annotations = {
      "kubernetes.io/ingress.class": "ingress-nginx-ingress-class"
    }
  }

  spec {
    rule {
      host = "apache.${var.ingress-domain}"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "apache-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
