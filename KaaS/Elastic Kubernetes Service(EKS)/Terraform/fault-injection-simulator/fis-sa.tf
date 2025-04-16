resource "kubernetes_service_account" "fis-sa" {
  metadata {
    name      = "fis-sa"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
}

resource "kubernetes_role" "role_experiments" {
  metadata {
    name      = "role-experiments"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "create", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["create", "list", "get", "delete", "deletecollection"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/ephemeralcontainers"]
    verbs      = ["update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "bind_role_experiments" {
  metadata {
    name      = "bind-role-experiments"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.fis-sa.metadata[0].name
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }

  subject {
    kind      = "User"
    name      = "fis-experiment"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.role_experiments.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}