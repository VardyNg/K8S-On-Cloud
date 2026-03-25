
resource "kubernetes_namespace_v1" "irsa" {
  metadata {
    name = "irsa-test"
  }
}

resource "kubernetes_service_account" "sa" {
  metadata {
    name = "irsa-test-sa"
    namespace = kubernetes_namespace_v1.irsa.metadata.0.name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_s3_list_buckets_role.arn
    }
  }

  depends_on = [ kubernetes_namespace_v1.irsa ]
}

resource "kubernetes_pod_v1" "pod" {
  metadata {
    name = "irsa-test-pod"
    namespace = kubernetes_namespace_v1.irsa.metadata.0.name
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

    service_account_name = kubernetes_service_account.sa.metadata.0.name
  }

  depends_on = [ kubernetes_namespace_v1.irsa ]
}