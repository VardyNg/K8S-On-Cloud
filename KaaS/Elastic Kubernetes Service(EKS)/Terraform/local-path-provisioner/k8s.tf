# Namespace for sample applications
resource "kubernetes_namespace" "sample_apps" {
  metadata {
    name = "sample-apps"
  }

  depends_on = [
    kubernetes_daemonset.local_volume_provisioner
  ]
}

# PersistentVolumeClaim using the fast-disks storage class
resource "kubernetes_persistent_volume_claim" "fast_disk_claim" {
  metadata {
    name      = "fast-disk-claim"
    namespace = kubernetes_namespace.sample_apps.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.fast_disks.metadata[0].name

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }

  wait_until_bound = false
}

# Deployment that uses the PersistentVolumeClaim
resource "kubernetes_deployment" "sample_app" {
  metadata {
    name      = "sample-app"
    namespace = kubernetes_namespace.sample_apps.metadata[0].name
    labels = {
      app = "sample-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "sample-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "sample-app"
        }
      }

      spec {
        node_selector = {
          "controller-node" = "true"
        }

        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "fast-storage"
            mount_path = "/data"
          }

          command = ["/bin/sh"]
          args = [
            "-c",
            <<-EOT
              echo "Starting continuous write to fast NVMe storage..."
              while true; do
                date >> /data/timestamps.log
                echo "Written at: $(date)" | tee -a /data/output.log
                sleep 1
              done
            EOT
          ]
        }

        volume {
          name = "fast-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.fast_disk_claim.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_persistent_volume_claim.fast_disk_claim
  ]
}
