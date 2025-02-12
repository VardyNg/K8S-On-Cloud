resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}

resource "kubernetes_manifest" "hamster_vpa" {
  manifest = {
    apiVersion = "autoscaling.k8s.io/v1"
    kind       = "VerticalPodAutoscaler"
    metadata = {
      name = "hamster-vpa"
      namespace = kubernetes_namespace_v1.ns.metadata.0.name
    }
    spec = {
      targetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = "hamster"
      }
      resourcePolicy = {
        containerPolicies = [
          {
            containerName      = "*"
            minAllowed = {
              cpu    = "100m"
              memory = "50Mi"
            }
            maxAllowed = {
              cpu    = "1"
              memory = "500Mi"
            }
            controlledResources = ["cpu", "memory"]
          }
        ]
      }
    }
  }
}

resource "kubernetes_deployment" "hamster" {
  metadata {
    name = "hamster"
    namespace  = kubernetes_namespace_v1.ns.metadata.0.name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "hamster"
      }
    }

    template {
      metadata {
        labels = {
          app = "hamster"
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 65534
        }

        container {
          name  = "hamster"
          image = "registry.k8s.io/ubuntu-slim:0.14"

          resources {
            requests = {
              cpu    = "100m"
              memory = "50Mi"
            }
          }

          command = ["/bin/sh"]
          args    = ["-c", "while true; do timeout 0.5s yes >/dev/null; sleep 0.5s; done"]
        }
      }
    }
  }
}