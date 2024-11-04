
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}


resource "kubernetes_storage_class_v1" "efs-sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  mount_options = ["tls"]
  parameters = {
    fileSystemId      = aws_efs_file_system.default.id
    provisioningMode  = "efs-ap"
    directoryPerms    = "700"
  }
  depends_on = [ aws_efs_file_system.default ]
}

resource "kubernetes_persistent_volume_claim_v1" "default" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class_v1.efs-sc.metadata.0.name
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
          image = "nginx:1.21.6"
          name  = "app"
          command = ["/bin/sh"]
          args = ["-c", "while true; do echo \"$(date -u) $(cat /etc/hostname)\" >> /data/out; sleep 5; done"]

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