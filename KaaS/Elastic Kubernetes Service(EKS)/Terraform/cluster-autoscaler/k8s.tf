resource "kubernetes_deployment_v1" "autoscaling_test_simple" {
  metadata {
    name      = "autoscaling-test-simple"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "autoscaling-test-simple"
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

resource "kubernetes_deployment_v1" "autoscaling_test_node_selector" {
  metadata {
    name      = "autoscaling-test-node-selector"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "autoscaling-test-node-selector"
      }
    }
    template {
      metadata {
        labels = {
          app = "autoscaling-test-node-selector"
        }
      }
      spec {
				node_selector = {
					"nodeClass" = "A"
				}

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