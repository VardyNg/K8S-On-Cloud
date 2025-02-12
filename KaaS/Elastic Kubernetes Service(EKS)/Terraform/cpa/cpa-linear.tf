resource "kubernetes_config_map" "nginx-linear-autoscaler" {
  metadata {
    name      = "nginx-linear-autoscaler"
    namespace = "default"
  }

  data = {
    linear = <<EOF
    {
      "coresPerReplica": 2,
      "nodesPerReplica": 1,
      "preventSinglePointFailure": true
    }
    EOF
  }
}

resource "kubernetes_deployment" "nginx-linear-autoscaler" {
  metadata {
    name      = "nginx-autoscaler-linear"
    namespace = "default"
    labels = {
      app = "autoscaler"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "autoscaler"
        }
      }


      spec {
        container {
          image = "registry.k8s.io/cpa/cluster-proportional-autoscaler-amd64:1.8.4"
          name  = "autoscaler"
          command = [
            "/cluster-proportional-autoscaler",
            "--namespace=default",
            "--configmap=${kubernetes_config_map.nginx-linear-autoscaler.metadata.0.name}",
            "--target=deployment/${kubernetes_deployment.nginx-linear.metadata.0.name}",
            "--logtostderr=true",
            "--v=2"
          ]
        }
        service_account_name = kubernetes_service_account.cluster_proportional_autoscaler.metadata.0.name
      }
    }
  }
}

resource "kubernetes_deployment" "nginx-linear" {
  metadata {
    name = "nginx-deployment-linear"
    labels = {
      app = "nginx"
    }
  }

  spec {

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx:1.14.2"
          name  = "nginx"

          port {
            container_port = 80
          }
        }
        
      }
    }
  }
}