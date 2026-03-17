
resource "kubernetes_namespace_v1" "s3-ns" {
  metadata {
    name = "s3-test"
  }
}

// Reference: https://github.com/awslabs/mountpoint-s3-csi-driver/blob/main/examples/kubernetes/static_provisioning/static_provisioning.yaml
resource "kubernetes_persistent_volume" "s3-default" {
  metadata {
    name = "s3-test-pv"
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

resource "kubernetes_persistent_volume_claim_v1" "s3-pvc" {
  metadata {
    name      = "s3-test-pvc"
    namespace = kubernetes_namespace_v1.s3-ns.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = ""
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.s3-default.metadata.0.name
  }
}

resource "kubernetes_deployment_v1" "s3-default" {
  metadata {
    name = "s3-test"
    namespace = kubernetes_namespace_v1.s3-ns.metadata.0.name
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
          args = ["-c", "echo 'Hello from the container!' >> /data/$(date -u).txt; tail -f /dev/null"]
      
          volume_mount {
            name = "persistent-storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.s3-pvc.metadata.0.name
          }
        }
      }
      
    }
  }
}
