
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}


resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
    labels = {
      app = "default"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "default"
      }
    }

    template {
      metadata {
        labels = {
          app = "default"
        }
      }

      spec {
        container {
          image = "busybox"
          name  = "logger"
          command = ["sh", "-c", "while true; do echo $(date) 'Hello from the log writer!'; sleep 5; done"]
        }

      }
      
    }
  }
}