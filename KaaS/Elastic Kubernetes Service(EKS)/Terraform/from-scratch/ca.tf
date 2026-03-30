resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
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
						image = "registry.k8s.io/autoscaling/cluster-autoscaler:v${var.eks_version}.0"

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

						// Auto discovery
						"--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${aws_eks_cluster.cluster.id}",

						// Specify the node group name for the cluster autoscaler
            # "--nodes=1:10:${aws_eks_node_group.ca-ng.}",

            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false",
            "--aws-use-static-instance-list",
            "--cluster-name=${aws_eks_cluster.cluster.id}"
          ]

          env {
            name  = "AWS_REGION"
            value = var.region
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
    name      = "cluster-autoscaler"
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
		resources  = ["events", "endpoints"]
		verbs      = ["create", "patch"]
	}

	rule {
		api_groups = [""]
		resources  = ["pods/eviction"]
		verbs      = ["create"]
	}

	rule {
		api_groups = [""]
		resources  = ["pods/status"]
		verbs      = ["update"]
	}

	rule {
		api_groups   = [""]
		resources    = ["endpoints"]
		resource_names = ["cluster-autoscaler"]
		verbs        = ["get", "update"]
	}

	rule {
		api_groups = [""]
		resources  = ["nodes"]
		verbs      = ["watch", "list", "get", "update"]
	}

  rule {
    api_groups = [""]
    resources  = [
      "namespaces",
      "pods",
      "services",
      "replicationcontrollers",
      "persistentvolumeclaims",
      "persistentvolumes"
    ]
    verbs = ["watch", "list", "get"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
		verbs      = ["get", "list", "watch", "update", "create"]
  }

	rule {
		api_groups = ["extensions"]
		resources  = ["replicasets", "daemonsets"]
		verbs      = ["watch", "list", "get"]
	}

	rule {
		api_groups = ["policy"]
		resources  = ["poddisruptionbudgets"]
		verbs      = ["watch", "list"]
	}

	rule {
		api_groups = ["apps"]
		resources  = ["statefulsets", "replicasets", "daemonsets"]
		verbs      = ["watch", "list", "get"]
	}

	rule {
		api_groups = ["storage.k8s.io"]
		resources  = ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
		verbs      = ["watch", "list", "get"]
	}

	rule {
		api_groups = ["batch", "extensions"]
		resources  = ["jobs"]
		verbs      = ["get", "list", "watch", "patch"]
	}

	rule {
		api_groups = ["coordination.k8s.io"]
		resources  = ["leases"]
		verbs      = ["create"]
	}

	rule {
		api_groups     = ["coordination.k8s.io"]
		resources      = ["leases"]
		resource_names = ["cluster-autoscaler"]
		verbs          = ["get", "update"]
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