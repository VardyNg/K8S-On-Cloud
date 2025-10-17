# Ingress using AWS Load Balancer Controller
resource "kubernetes_ingress_v1" "nginx_alb_lbc" {
  metadata {
    name      = "nginx-alb-lbc-ingress"
    namespace = "default"
    
    annotations = {
      # Specify the ingress class for AWS Load Balancer Controller
      "kubernetes.io/ingress.class" = "alb"
      
      # ALB scheme - internet-facing or internal
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      
      # Target type - ip or instance
      "alb.ingress.kubernetes.io/target-type" = "ip"

			# Testing success-code annotation 
			"alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
			"alb.ingress.kubernetes.io/healthcheck-port" = "traffic-port"
			"alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
			"alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
			"alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = "5"
			"alb.ingress.kubernetes.io/healthy-threshold-count" = "3"
			"alb.ingress.kubernetes.io/unhealthy-threshold-count" = "3"
			"alb.ingress.kubernetes.io/success-codes" = "200,302"
    }
    
    labels = {
      app = "nginx"
    }
  }

  spec {
    # Use the standard ALB ingress class for AWS Load Balancer Controller
    ingress_class_name = "alb"
    
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = "nginx-service"  # Reference the nginx service
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
    helm_release.lb_controller  # Ensure AWS Load Balancer Controller is installed
  ]
}
