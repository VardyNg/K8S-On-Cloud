resource "kubernetes_deployment" "ca_test" {
  metadata {
    name      = "ca-test-workload"
    namespace = "default"
  }

  spec {
    replicas = 10

    selector {
      match_labels = {
        app = "ca-test"
      }
    }

    template {
      metadata {
        labels = {
          app = "ca-test"
        }
      }

      spec {
        node_selector = {
          "scaling-group" = "cluster-autoscaler"
        }

        container {
          name  = "pause"
          image = "registry.k8s.io/pause:3.9"

          resources {
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    aws_eks_node_group.ca-ng,
    helm_release.cluster_autoscaler
  ]
}
