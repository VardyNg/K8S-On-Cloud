resource "kubernetes_service_v1" "nlb-by-service" {
  metadata {
    name = "nlb-by-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-name": "${local.name}-by-service"
      "service.beta.kubernetes.io/aws-load-balancer-type": "external"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type": "ip"
      "service.beta.kubernetes.io/aws-load-balancer-listener-attributes.TCP-80": "tcp.idle_timeout.seconds=600"
      "service.beta.kubernetes.io/aws-load-balancer-scheme": "internet-facing"
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