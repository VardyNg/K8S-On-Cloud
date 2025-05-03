
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}


resource "kubernetes_storage_class_v1" "ebs-sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  # volume_binding_mode = "WaitForFirstConsumer"
}


resource "kubernetes_persistent_volume_claim_v1" "default" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class_v1.ebs-sc.metadata.0.name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
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
          image = "centos:8"
          name  = "app"
          command = ["/bin/sh"]
          args = ["-c", "while true; do echo $(date -u) >> /data/out; sleep 5; done"]

          volume_mount {
            name = "persistent-storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.default.metadata.0.name
          }
        }
      }
      
    }
  }
}
