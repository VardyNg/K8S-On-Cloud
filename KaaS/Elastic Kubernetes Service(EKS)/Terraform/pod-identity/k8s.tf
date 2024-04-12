
resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "${local.name}-namespace"
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name = "${local.name}-sa"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }

  depends_on = [ kubernetes_namespace_v1.ns ]
}

resource "kubernetes_pod_v1" "pod" {
  metadata {
    name = "${local.name}-pod"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }

  spec {
    container {
      image = "amazon/aws-cli"
      name  = "awscli" 
      args = ["s3", "ls"]
    }

    service_account_name = kubernetes_service_account.sa.metadata.0.name
  }

  depends_on = [ kubernetes_namespace_v1.ns ]
}