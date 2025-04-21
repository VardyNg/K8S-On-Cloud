resource "kubernetes_namespace" "sample-app" {
  metadata {
    name = "sample-app"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "sample-app-nginx-deployment"
    namespace = kubernetes_namespace.sample-app.metadata[0].name
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
    name = "sample-app-nginx-service"
    namespace = kubernetes_namespace.sample-app.metadata[0].name

  }
  
  spec {
    selector = {
      app = "nginx"
    }

    
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name = "sample-app-nginx-ingress"
    namespace = kubernetes_namespace.sample-app.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class": "nginx"
    }
  }

  spec {
    rule {
      host = "nginx.example.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.nginx.metadata[0].name
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