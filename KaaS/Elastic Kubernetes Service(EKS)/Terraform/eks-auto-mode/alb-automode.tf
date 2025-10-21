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
      "ingressclass.kubernetes.io/is-default-class" = "false"
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
# resource "kubernetes_ingress_v1" "nginx_alb" {
#   metadata {
#     name      = "nginx-alb-ingress"
#     namespace = "default"
    
#     labels = {
#       app = "nginx"
#     }
#   }

#   spec {
#     # Reference the IngressClass
#     ingress_class_name = kubernetes_ingress_class_v1.alb.metadata[0].name
    
#     rule {
#       http {
#         path {
#           path      = "/*"
#           path_type = "ImplementationSpecific"
          
#           backend {
#             service {
#               name = kubernetes_service_v1.nginx.metadata[0].name
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [
#     kubernetes_service_v1.nginx,
#     kubernetes_deployment_v1.nginx,
#     kubernetes_ingress_class_v1.alb
#   ]
# }