resource "kubernetes_namespace" "sample-app" {
  metadata {
    name = "sample-app"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 5
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
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nginx" {
  metadata {
    name = "nginx-service"

    annotations = {
      "kubernetes.io/ingress.class": "prod-public-ingress"
    }
  }
  
  spec {
    selector = {
      app = "nginx"
    }

    
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name = "nginx-ingress"

    annotations = {
      "kubernetes.io/ingress.class": "prod-public-ingress"
    }
  }

  spec {
    rule {
      host = var.ingress-host
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "nginx-service"
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