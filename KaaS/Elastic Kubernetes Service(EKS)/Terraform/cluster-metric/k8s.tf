# Namespace for metric scraping
resource "kubernetes_namespace" "metric" {
  metadata {
    name = "metric"
  }
}

# ServiceAccount for the DaemonSet
resource "kubernetes_service_account" "metric_scraper" {
  metadata {
    name      = "metric-scraper"
    namespace = kubernetes_namespace.metric.metadata[0].name
  }
}

# ClusterRole allowing proxy access to node endpoints (used to reach host metrics via API proxy)
resource "kubernetes_cluster_role" "metric_scraper" {
  metadata {
    name = "metric-scraper-clusterrole"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get", "list", "watch"]
  }
}

# Bind the ClusterRole to the ServiceAccount
resource "kubernetes_cluster_role_binding" "metric_scraper" {
  metadata {
    name = "metric-scraper-binding"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.metric_scraper.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metric_scraper.metadata[0].name
    namespace = kubernetes_service_account.metric_scraper.metadata[0].namespace
  }
}

# DaemonSet that scrapes the /metrics/advisotr endpoint on each node via the API server node proxy
resource "kubernetes_daemonset" "metric_scraper" {
  metadata {
    name      = "metric-scraper"
    namespace = kubernetes_namespace.metric.metadata[0].name
    labels = {
      app = "metric-scraper"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "metric-scraper"
      }
    }

    template {
      metadata {
        labels = {
          app = "metric-scraper"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.metric_scraper.metadata[0].name
        termination_grace_period_seconds = 30

        container {
          name  = "scraper"
          image = "curlimages/curl:8.1.2"
          image_pull_policy = "IfNotPresent"

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          command = ["/bin/sh"]
          args = [
            "-c",
            <<-EOT
              # Get the service account token for API server authentication
              TOKEN=$$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
              CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
              KUBERNETES_SERVICE_HOST=$${KUBERNETES_SERVICE_HOST:-kubernetes.default.svc}
              KUBERNETES_SERVICE_PORT=$${KUBERNETES_SERVICE_PORT:-443}
              
              echo "Starting metric scraper for node: $$NODE_NAME"
              
              # Infinite loop to curl metrics every 5 seconds
              while true; do
                echo "$$(date): Scraping metrics from node: $$NODE_NAME"
                
                # Curl the node metrics endpoint via API server proxy
                # This endpoint provides cAdvisor metrics from the kubelet
                curl -s \
                  --cacert "$$CA_CERT" \
                  -H "Authorization: Bearer $$TOKEN" \
                  "https://$$KUBERNETES_SERVICE_HOST:$$KUBERNETES_SERVICE_PORT/api/v1/nodes/$$NODE_NAME/proxy/metrics/cadvisor" \
                  --connect-timeout 10 \
                  --max-time 30 \
                  || echo "$$(date): Failed to scrape metrics from node: $$NODE_NAME"
                
                echo "$$(date): Completed metrics scrape for node: $$NODE_NAME"
                echo "---"
                
                # Wait 5 seconds before next scrape
                sleep 5
              done
            EOT
          ]

          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }

        # tolerate all taints so this daemonset runs on control/infra nodes if needed
        toleration {
          key      = ""
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
}
