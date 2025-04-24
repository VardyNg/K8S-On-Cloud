
resource "helm_release" "csi_driver_lvm" {
  name       = "csi-driver-lvm"
  repository = "https://helm.metal-stack.io"
  chart      = "csi-driver-lvm"
  version    = "0.5.2"

  set {
    name  = "lvm.devicePattern"
    value = "/dev/nvme[1-9]n[0-9]"
  }
}