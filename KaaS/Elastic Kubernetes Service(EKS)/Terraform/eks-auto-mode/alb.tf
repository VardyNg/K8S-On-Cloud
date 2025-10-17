# EKS Auto Mode ALB Configuration
# This configuration follows the EKS Auto Mode approach for creating Application Load Balancers
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-alb.html
#
# Key differences from AWS Load Balancer Controller:
# - Uses IngressClass with controller: eks.amazonaws.com/alb
# - Uses IngressClassParams for AWS-specific configuration
# - No longer uses alb.ingress.kubernetes.io annotations
# - Uses path type "ImplementationSpecific" with "/*" pattern

# Nginx Deployment
resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = "default"
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
          image = "nginx:1.25"
          
          port {
            container_port = 80
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          # Add a simple custom index.html
          volume_mount {
            name       = "nginx-config"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map_v1.nginx_config.metadata[0].name
          }
        }
      }
    }
  }
}

# ConfigMap for custom nginx content
resource "kubernetes_config_map_v1" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = "default"
  }

  data = {
    "index.html" = <<-EOT
      <!DOCTYPE html>
      <html>
      <head>
          <title>EKS Auto Mode - ALB Demo</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                  color: white;
                  text-align: center;
                  padding: 50px;
              }
              .container {
                  background: rgba(255, 255, 255, 0.1);
                  padding: 30px;
                  border-radius: 10px;
                  backdrop-filter: blur(10px);
                  max-width: 600px;
                  margin: 0 auto;
              }
              h1 { color: #fff; margin-bottom: 20px; }
              .info { margin: 10px 0; font-size: 18px; }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>🚀 EKS Auto Mode with ALB</h1>
              <div class="info">✅ Nginx deployment running successfully</div>
              <div class="info">🔄 Load balanced by AWS Application Load Balancer</div>
              <div class="info">⚡ Powered by EKS Auto Mode</div>
              <div class="info">🌐 Built-in AWS Load Balancer Controller</div>
              <p>Hostname: <span id="hostname"></span></p>
          </div>
          <script>
              document.getElementById('hostname').textContent = window.location.hostname;
          </script>
      </body>
      </html>
    EOT
  }
}

# Service for nginx deployment
resource "kubernetes_service_v1" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = "default"
    labels = {
      app = "nginx"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# IngressClassParams for EKS Auto Mode ALB configuration
resource "kubernetes_manifest" "alb_ingress_class_params" {
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "IngressClassParams"
    metadata = {
      name = "alb-nginx"
    }
    spec = {
      scheme = "internet-facing"
    }
  }
}

# IngressClass for EKS Auto Mode
resource "kubernetes_ingress_class_v1" "alb" {
  metadata {
    name = "alb-nginx"
    annotations = {
      # Set as default IngressClass if desired
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    # EKS Auto Mode controller
    controller = "eks.amazonaws.com/alb"
    
    parameters {
      api_group = "eks.amazonaws.com"
      kind      = "IngressClassParams"
      name      = kubernetes_manifest.alb_ingress_class_params.manifest.metadata.name
    }
  }
}

# Ingress to create ALB using EKS Auto Mode
resource "kubernetes_ingress_v1" "nginx_alb" {
  metadata {
    name      = "nginx-alb-ingress"
    namespace = "default"
    
    labels = {
      app = "nginx"
    }
  }

  spec {
    # Reference the IngressClass
    ingress_class_name = kubernetes_ingress_class_v1.alb.metadata[0].name
    
    rule {
      http {
        path {
          path      = "/*"
          path_type = "ImplementationSpecific"
          
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

  depends_on = [
    kubernetes_service_v1.nginx,
    kubernetes_deployment_v1.nginx,
    kubernetes_ingress_class_v1.alb
  ]
}