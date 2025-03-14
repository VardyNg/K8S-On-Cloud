resource "kubernetes_namespace" "batch" {
  metadata {
    name = "aws-batch"
  }
}

resource "kubernetes_cluster_role" "aws_batch_cluster_role" {
  metadata {
    name = "aws-batch-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets", "deployments", "statefulsets", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "aws_batch_cluster_role_binding" {
  metadata {
    name = "aws-batch-cluster-role-binding"
  }

  subject {
    kind      = "User"
    name      = "aws-batch"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.aws_batch_cluster_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role" "aws_batch_compute_environment_role" {
  metadata {
    name      = "aws-batch-compute-environment-role"
    namespace = kubernetes_namespace.batch.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["create", "get", "list", "watch", "delete", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "aws_batch_compute_environment_role_binding" {
  metadata {
    name      = "aws-batch-compute-environment-role-binding"
    namespace = kubernetes_namespace.batch.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "aws-batch"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.aws_batch_compute_environment_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}