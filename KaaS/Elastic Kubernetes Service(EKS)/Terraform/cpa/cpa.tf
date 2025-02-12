resource "kubernetes_service_account" "cluster_proportional_autoscaler" {
  metadata {
    name      = "cluster-proportional-autoscaler"
    namespace = "default"
  }
}

resource "kubernetes_cluster_role" "cluster_proportional_autoscaler" {
  metadata {
    name = "cluster-proportional-autoscaler"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["replicationcontrollers/scale"]
    verbs      = ["get", "update"]
  }

  rule {
    api_groups = ["extensions", "apps"]
    resources  = ["deployments/scale", "replicasets/scale"]
    verbs      = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_proportional_autoscaler" {
  metadata {
    name = "cluster-proportional-autoscaler"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cluster-proportional-autoscaler"
    namespace = "default"
  }

  role_ref {
    kind     = "ClusterRole"
    name     = "cluster-proportional-autoscaler"
    api_group = "rbac.authorization.k8s.io"
  }
}