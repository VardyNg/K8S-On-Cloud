resource "kubernetes_deployment" "php_apache" {
  metadata {
    name = "php-apache"
  }

  spec {
    selector {
      match_labels = {
        run = "php-apache"
      }
    }

    template {
      metadata {
        labels = {
          run = "php-apache"
        }
      }

      spec {
        container {
          name  = "php-apache"
          image = "registry.k8s.io/hpa-example"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu = "500m"
            }
            requests = {
              cpu = "200m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "php_apache" {
  metadata {
    name = "php-apache"
    labels = {
      run = "php-apache"
    }
  }

  spec {
    port {
      port = 80
    }

    selector = {
      run = "php-apache"
    }
  }
}


resource "kubernetes_horizontal_pod_autoscaler_v2" "php_apache" {
  metadata {
    name = "php-apache"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "php-apache"
    }

    min_replicas = 1
    max_replicas = 10

    metric {
      type = "Resource"

      resource {
        name = "cpu"
        target {
          type               = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}
