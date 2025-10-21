# Example Kubernetes Deployment with ASCP - based on AWS documentation
# Reference: https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_ascp_irsa.html

locals {
	deployment_sa = "sa"
}

resource "kubernetes_namespace" "example" {
	metadata {
		name = "example"
	}
}

# Service account for the deployment with IRSA annotation
resource "kubernetes_service_account" "nginx_irsa_sa" {
  metadata {
    name      = local.deployment_sa
    namespace = kubernetes_namespace.example.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ascp_irsa.arn
    }
  }
}

# Deployment with 3 replicas - based on AWS example
resource "kubernetes_deployment" "nginx_irsa" {
  metadata {
    name      = "nginx-irsa-deployment"
    namespace = kubernetes_namespace.example.metadata[0].name
    labels = {
      app = "nginx-irsa"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx-irsa"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-irsa"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.nginx_irsa_sa.metadata[0].name

        volume {
          name = "secrets-store-inline"
          csi {
            driver        = "secrets-store.csi.k8s.io"
            read_only     = true
            volume_attributes = {
              secretProviderClass = "nginx-irsa-deployment-aws-secrets"
            }
          }
        }

        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "secrets-store-inline"
            mount_path = "/mnt/secrets-store"
            read_only  = true
          }

          # Command to display the secret in logs
          command = [
            "/bin/sh",
            "-c",
            "echo 'Secret mounted at /mnt/secrets-store:' && cat /mnt/secrets-store/* && nginx -g 'daemon off;' || tail -f /dev/null"
          ]

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.secret_provider_class]
}
