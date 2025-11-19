# ServiceAccount for Local Volume Static Provisioner
resource "kubernetes_service_account" "local_volume_provisioner" {
  metadata {
    name      = "local-volume-provisioner"
    namespace = "kube-system"
  }
}

# ClusterRole with permissions for the CSI driver
resource "kubernetes_cluster_role" "local_storage_provisioner" {
  metadata {
    name = "local-storage-provisioner-node-clusterrole"
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["watch"]
  }

  rule {
    api_groups = ["", "events.k8s.io"]
    resources  = ["events"]
    verbs      = ["create", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get"]
  }
}

# ClusterRoleBinding to attach the ClusterRole to the ServiceAccount
resource "kubernetes_cluster_role_binding" "local_storage_provisioner" {
  metadata {
    name = "local-storage-provisioner-node-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.local_storage_provisioner.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.local_volume_provisioner.metadata[0].name
    namespace = "kube-system"
  }
}

# StorageClass for fast-disks
resource "kubernetes_storage_class" "fast_disks" {
  metadata {
    name = "fast-disks"
  }

  storage_provisioner    = "kubernetes.io/no-provisioner"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = false
}

# ConfigMap with configuration for the Local Volume Static Provisioner
resource "kubernetes_config_map" "local_volume_provisioner" {
  metadata {
    name      = "local-volume-provisioner-config"
    namespace = "kube-system"
  }

  data = {
    nodeLabelsForPV = <<-EOT
      - kubernetes.io/hostname
    EOT

    storageClassMap = <<-EOT
      fast-disks:
        hostDir: /mnt/fast-disks
        mountDir: /mnt/fast-disks
        blockCleanerCommand:
          - "/scripts/shred.sh"
          - "2"
        volumeMode: Filesystem
        fsType: ext4
        namePattern: "*"
    EOT
  }
}

# DaemonSet for the Local Volume Static Provisioner
resource "kubernetes_daemonset" "local_volume_provisioner" {
  metadata {
    name      = "local-volume-provisioner"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "local-volume-provisioner"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "local-volume-provisioner"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "local-volume-provisioner"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.local_volume_provisioner.metadata[0].name

        container {
          name              = "provisioner"
          image             = "registry.k8s.io/sig-storage/local-volume-provisioner:v2.5.0"
          image_pull_policy = "Always"

          security_context {
            privileged = true
          }

          env {
            name = "MY_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "MY_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          port {
            name           = "metrics"
            container_port = 8080
          }

          volume_mount {
            name       = "provisioner-config"
            mount_path = "/etc/provisioner/config"
            read_only  = true
          }

          volume_mount {
            name              = "fast-disks"
            mount_path        = "/mnt/fast-disks"
            mount_propagation = "HostToContainer"
          }
        }

        volume {
          name = "provisioner-config"
          config_map {
            name = kubernetes_config_map.local_volume_provisioner.metadata[0].name
          }
        }

        volume {
          name = "fast-disks"
          host_path {
            path = "/mnt/fast-disks"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.local_volume_provisioner,
    kubernetes_cluster_role_binding.local_storage_provisioner,
    kubernetes_config_map.local_volume_provisioner,
    kubernetes_storage_class.fast_disks
  ]
}
