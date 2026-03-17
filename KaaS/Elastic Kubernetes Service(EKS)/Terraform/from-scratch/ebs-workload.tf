
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.56.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_role.arn

  depends_on = [
    aws_eks_node_group.default
  ]
}

resource "kubernetes_namespace_v1" "ebs-ns" {
  metadata {
    name = "ebs-test"
  }
}


resource "kubernetes_storage_class_v1" "ebs-sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  # volume_binding_mode = "WaitForFirstConsumer"
}


resource "kubernetes_persistent_volume_claim_v1" "ebs-default" {
  metadata {
    name = "ebs-test-pvc"
    namespace = kubernetes_namespace_v1.ebs-ns.metadata.0.name
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


resource "kubernetes_deployment_v1" "ebs-default" {
  metadata {
    name = "ebs-test"
    namespace = kubernetes_namespace_v1.ebs-ns.metadata.0.name
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
        node_selector = {
          "kubernetes.io/os" = "linux"
        }

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
            claim_name = kubernetes_persistent_volume_claim_v1.ebs-default.metadata.0.name
          }
        }
      }
      
    }
  }
}
