resource "kubernetes_config_map" "nginx-ladder-autoscaler" {
  metadata {
    name      = "nginx-ladder-autoscaler"
    namespace = "default"
  }

  data = {
    ladder = <<EOF
    {
      "coresToReplicas":
      [
        [ 1,1 ],
        [ 3,3 ],
        [ 5,5 ],
        [ 7,7 ]
      ],
      "nodesToReplicas":
      [
        [ 1,1 ],
        [ 2,2 ]
      ]
    }
    EOF
  }
}

resource "kubernetes_deployment" "nginx-ladder-autoscaler" {
  metadata {
    name      = "nginx-autoscaler-ladder"
    namespace = "default"
    labels = {
      app = "autoscaler"
    }
  }

  spec {

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
            "--configmap=${kubernetes_config_map.nginx-ladder-autoscaler.metadata.0.name}",
            "--target=deployment/${kubernetes_deployment.nginx-ladder.metadata.0.name}",
            "--logtostderr=true",
            "--v=2"
          ]
        }
        service_account_name = kubernetes_service_account.cluster_proportional_autoscaler.metadata.0.name
      }
    }
  }
}

resource "kubernetes_deployment" "nginx-ladder" {
  metadata {
    name = "nginx-deployment-ladder"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

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
        service_account_name = kubernetes_service_account.cluster_proportional_autoscaler.metadata.0.name
      }
    }
  }
}