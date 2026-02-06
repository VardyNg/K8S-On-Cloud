# Namespace for OOMKilled testing
resource "kubernetes_namespace" "oom_test" {
  metadata {
    name = "oom-test"
    labels = {
      purpose = "oom-kill-testing"
    }
  }
}

# Deployment that will allocate more memory than its limit and get OOMKilled repeatedly
# Uses a small stress image to allocate memory. The container requests a small amount
# but the stress process allocates ~200Mi, which will exceed the 50Mi limit below.
resource "kubernetes_deployment" "oom_demo" {
	
  metadata {
    name      = "oom-demo"
    namespace = kubernetes_namespace.oom_test.metadata[0].name
    labels = {
      app = "oom-demo"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "oom-demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "oom-demo"
        }
      }

      spec {
        # Keep restarting on failure so the pod repeatedly hits OOMKilled for testing
        container {
          name  = "memory-hog"
          image_pull_policy = "IfNotPresent"
          image = "polinux/stress:latest"
					command = ["stress"]
          # Allocate ~200M in memory which will exceed the container limit below
          args = ["--vm", "1", "--vm-bytes", "256M", "--vm-hang", "1"]

          resources {
            limits = {
              memory = "50Mi"
            }
            requests = {
              memory = "20Mi"
            }
          }
        }

        # Reduce grace time so restarts happen quickly (optional)
        termination_grace_period_seconds = 0
      }
    }
  }
}


resource "kubernetes_deployment" "oom_demo_2" {
  metadata {
    name      = "oom-demo-2"
    namespace = kubernetes_namespace.oom_test.metadata[0].name
    labels = {
      app = "oom-demo-2"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "oom-demo-2"
      }
    }

    template {
      metadata {
        labels = {
          app = "oom-demo-2"
        }
      }

      spec {
        # Keep restarting on failure so the pod repeatedly hits OOMKilled for testing
        container {
          name  = "memory-hog"
          image_pull_policy = "IfNotPresent"
          image = "polinux/stress:latest"
					command = ["stress"]
          # Allocate ~200M in memory which will exceed the container limit below
          args = ["--vm", "1", "--vm-bytes", "256M", "--vm-hang", "1"]

          resources {
            limits = {
              memory = "50Mi"
            }
            requests = {
              memory = "20Mi"
            }
          }
        }

        # Reduce grace time so restarts happen quickly (optional)
        termination_grace_period_seconds = 0
      }
    }
  }
}