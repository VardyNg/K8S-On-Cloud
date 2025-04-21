resource "kubernetes_deployment_v1" "autoscaling_test" {
  metadata {
    name      = "autoscaling-test"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "autoscaling-test"
      }
    }
    template {
      metadata {
        labels = {
          app = "autoscaling-test"
        }
      }
      spec {
        container {
          name  = "busybox"
          image = "busybox"
          args  = ["/bin/sh", "-c", "while true; do echo 'Hello, Kubernetes!'; sleep 10; done"]
          resources {
            requests = {
              cpu    = "0.5"
              memory = "1G"
            }
            limits = {
              cpu    = "0.5"
              memory = "1G"
            }
          }
        }
      }
    }
  }
}

