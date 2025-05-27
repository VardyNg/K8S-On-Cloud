

resource "kubernetes_storage_class_v1" "efs-sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  mount_options = ["tls", "iam"]
  parameters = {
    fileSystemId      = aws_efs_file_system.default.id
    provisioningMode  = "efs-ap"
    directoryPerms    = "700"
    gidRangeEnd       = 2000
    gidRangeStart     = 1000
    accessPointId     = aws_efs_access_point.efs.id
  }
  depends_on = [ aws_efs_file_system.default ]
}

resource "kubernetes_persistent_volume_claim_v1" "default" {
  metadata {
    name = "runner-work-pvc"
    namespace = kubernetes_namespace.arc_runners.metadata.0.name
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