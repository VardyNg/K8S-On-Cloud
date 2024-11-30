resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    name      = "${local.name}-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.cluster_autoscaler.metadata[0].name

        container {
          name  = "cluster-autoscaler"
          image = "registry.k8s.io/autoscaling/cluster-autoscaler:v1.29.3"

          command = [
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false",
            "--aws-use-static-instance-list",
            "--nodes=1:10:${module.eks.eks_managed_node_groups.initial.node_group_autoscaling_group_names[0]}",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false",
            "--aws-use-static-instance-list",
            "--cluster-name=${module.eks.cluster_name}"
          ]

          env {
            name  = "AWS_REGION"
            value = local.name
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "${local.name}-cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}


resource "kubernetes_cluster_role" "cluster_autoscaler" {
  metadata {
    name = "${local.name}-cluster-autoscaler"
  }

  rule {
    api_groups = [""]
    resources  = ["events", "endpoints", "pods", "services", "replicationcontrollers", "replicasets", "nodes"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["*"]
    verbs      = ["create", "get", "list", "watch", "update", "patch"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "list", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "cluster_autoscaler" {
  metadata {
    name = "cluster-autoscaler"
  }

  role_ref {
    kind = "ClusterRole"
    name = kubernetes_cluster_role.cluster_autoscaler.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cluster_autoscaler.metadata[0].name
    namespace = kubernetes_service_account.cluster_autoscaler.metadata[0].namespace
  }
}