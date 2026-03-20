
resource "kubernetes_namespace_v1" "cw-ns" {
  metadata {
    name = "cloudwatch-log-test"
  }
}

# RBAC for Fluent Bit to access Kubernetes events
resource "kubernetes_cluster_role_v1" "fluent_bit_events" {
  metadata {
    name = "fluent-bit-events"
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "fluent_bit_events" {
  metadata {
    name = "fluent-bit-events"
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.fluent_bit_events.metadata.0.name
  }
  
  subject {
    kind      = "ServiceAccount"
    name      = "cloudwatch-agent"
    namespace = "amazon-cloudwatch"
  }
}


resource "kubernetes_deployment_v1" "default" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace_v1.cw-ns.metadata.0.name
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
          image   = "busybox"
          name    = "logger"
          command = ["sh", "-c", "while true; do echo $(date) 'Hello from the log writer!'; sleep 5; done"]
        }
      }
    }
  }
}