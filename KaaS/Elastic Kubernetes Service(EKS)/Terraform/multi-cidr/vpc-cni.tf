resource "kubernetes_manifest" "eni_config" {

  manifest = {
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = "eni-config-1"
    }
    spec = {
      securityGroups = [
        module.eks.node_security_group_id
      ]
      subnet         = aws_subnet.additional.id
    }
  }
}
