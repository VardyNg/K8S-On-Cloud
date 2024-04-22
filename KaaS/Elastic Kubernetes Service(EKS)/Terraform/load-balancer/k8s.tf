
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

resource "kubernetes_ingress_v1" "nginx-1" {
  metadata {
    name = "nginx-ingress-1"
    annotations = {
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port": 80
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP": 80}, {"HTTPS": 443}])
      "alb.ingress.kubernetes.io/target-type": "ip"
      "alb.ingress.kubernetes.io/group.name" = "sample-ingress-group"
      "alb.ingress.kubernetes.io/group.order" = 1
      "alb.ingress.kubernetes.io/inbound-cidrs" = "10.0.0.0/24"
      "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate.ingress-1.arn}"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "*.${var.domain_2}"
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

resource "kubernetes_ingress_v1" "nginx-2" {
  metadata {
    name = "nginx-ingress-2"
    annotations = {
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port": 80
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP": 80}, {"HTTPS": 443}])
      "alb.ingress.kubernetes.io/target-type": "ip"
      "alb.ingress.kubernetes.io/group.name" = "sample-ingress-group"
      "alb.ingress.kubernetes.io/group.order" = 2
      "alb.ingress.kubernetes.io/inbound-cidrs" = "10.0.0.0/24"
      "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate.ingress-2.arn}"
    }
  }

  spec {
    ingress_class_name = "alb"
    
    rule {
      host = "*.${var.domain_2}"
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

resource "kubernetes_ingress_v1" "nginx-3" {
  metadata {
    name = "nginx-ingress-3"
    annotations = {
      "alb.ingress.kubernetes.io/scheme": "internal"
      "alb.ingress.kubernetes.io/healthcheck-protocol": "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port": 80
      "alb.ingress.kubernetes.io/listen-ports": jsonencode([{"HTTP": 80}, {"HTTPS": 443}])
      "alb.ingress.kubernetes.io/target-type": "ip"
      "alb.ingress.kubernetes.io/inbound-cidrs" = "10.0.0.0/24"
      "alb.ingress.kubernetes.io/certificate-arn" = "${aws_acm_certificate.ingress-1.arn},${aws_acm_certificate.ingress-2.arn}"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "*.${var.domain_1}"
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
      host = "*.${var.domain_2}"
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

