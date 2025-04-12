resource "kubernetes_ingress_v1" "alb-by-ingress" {
  metadata {
    name = "alb-by-ingress"
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name": "${local.name}-by-ingress"
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port": 80
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP": 80}])
      "alb.ingress.kubernetes.io/target-type": "ip"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path_type = "Prefix"
          path = "/"
          backend {
            service {
              name = kubernetes_service_v1.nginx.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    rule {
      http {
        path {
          path_type = "Prefix"
          path = "/prefix"
          backend {
            service {
              name = kubernetes_service_v1.nginx.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      http {
        path {
          path_type = "Exact"
          path = "/test/"
          backend {
            service {
              name = kubernetes_service_v1.nginx.metadata.0.name
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
