resource "kubernetes_ingress_v1" "alb-ingress-group-member-1" {
  metadata {
    name = "alb-ingress-group-member-1"
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name": "${local.name}-with-group"

      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port": 80
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP": 80}])
      "alb.ingress.kubernetes.io/target-type": "ip"
      "alb.ingress.kubernetes.io/group.name" = "sample-ingress-group"
      "alb.ingress.kubernetes.io/group.order" = 1
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/hello/"
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

resource "kubernetes_ingress_v1" "alb-ingress-group-member-2" {
  metadata {
    name = "alb-ingress-group-member-2"
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port": 80
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP": 80}])
      "alb.ingress.kubernetes.io/target-type": "ip"
      "alb.ingress.kubernetes.io/group.name" = "sample-ingress-group"
      "alb.ingress.kubernetes.io/group.order" = 2
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
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