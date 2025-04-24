resource "kubernetes_namespace" "sample-app" {
  metadata {
    name = "sample-app"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "default" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace.sample-app.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]

    storage_class_name = "csi-driver-lvm-striped"

    resources {
      requests = {
        storage = "1200Gi"
      }
    }
  }

  wait_until_bound = false
}


resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace.sample-app.metadata.0.name
    labels = {
      app = "default"
    }
  }

  spec {
    replicas = 1

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
