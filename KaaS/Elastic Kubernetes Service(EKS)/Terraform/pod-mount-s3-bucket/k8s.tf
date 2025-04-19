
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}

// Reference: https://github.com/awslabs/mountpoint-s3-csi-driver/blob/main/examples/kubernetes/static_provisioning/static_provisioning.yaml
resource "kubernetes_persistent_volume" "default" {
  metadata {
    name = "${local.name}-pv"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = ""
    mount_options = [
      "region ${aws_s3_bucket.default.region}"
    ]

    persistent_volume_source {
      csi {
        driver = "s3.csi.aws.com"
        volume_handle = "s3-csi-driver-volume"
        volume_attributes = {
          bucketName: aws_s3_bucket.default.id
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "pvc" {
  metadata {
    name      = "${local.name}-pvc"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = ""
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.default.metadata.0.name
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
          image = "centos"
          name  = "app"
          command = ["/bin/sh"]
          args = ["-c", "echo 'Hello from the container!' >> /data/$(date -u).txt; tail -f /dev/null"]
      
          volume_mount {
            name = "persistent-storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_manifest.pvc.manifest.metadata.name
          }
        }
      }
      
    }
  }
}
