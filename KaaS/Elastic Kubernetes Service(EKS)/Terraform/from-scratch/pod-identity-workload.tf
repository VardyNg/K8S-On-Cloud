
resource "kubernetes_namespace_v1" "pod-identity" {
  metadata {
    name = "pod-identity"
  }
}

resource "kubernetes_service_account" "pod-identity-sa" {
  metadata {
    name = "pod-identity-sa"
    namespace = kubernetes_namespace_v1.pod-identity.metadata.0.name
  }

  depends_on = [ kubernetes_namespace_v1.pod-identity ]
}

resource "kubernetes_pod_v1" "pod-identity-pod" {
  metadata {
    name = "pod-identity-pod"
    namespace = kubernetes_namespace_v1.pod-identity.metadata.0.name
  }

  spec {
		node_selector = {
      "kubernetes.io/os" = "linux"
		}

    container {
      image = "amazon/aws-cli"
      name  = "awscli" 
      command = ["/bin/sh", "-c", "while true; do aws s3 ls; sleep 60; done"]
    }

    service_account_name = kubernetes_service_account.pod-identity-sa.metadata.0.name
  }

  depends_on = [ kubernetes_namespace_v1.pod-identity ]
}