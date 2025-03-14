# https://docs.aws.amazon.com/eks/latest/userguide/create-storage-class.html
resource "kubernetes_storage_class" "auto_ebs_sc" {
  metadata {
    name = "auto-ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.eks.amazonaws.com"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "default" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_storage_class.auto_ebs_sc.metadata.0.name
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }

  wait_until_bound = false
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