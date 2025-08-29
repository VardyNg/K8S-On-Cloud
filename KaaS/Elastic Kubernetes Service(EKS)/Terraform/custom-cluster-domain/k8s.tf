resource "kubernetes_daemonset" "dnsutils" {
  metadata {
    name      = "dnsutils"
    namespace = "default"
  }
  spec {
    selector {
      match_labels = {
        name = "dnsutils"
      }
    }
    template {
      metadata {
        labels = {
          name = "dnsutils"
        }
      }
      spec {
        container {
          name    = "dnsutils"
          image   = "tutum/dnsutils"
          command = ["sleep", "3600"]
        }
      }
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-sample"
    namespace = "default"
    labels = {
      app = "nginx-sample"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx-sample"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx-sample"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-sample"
    namespace = "default"
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.metadata[0].labels["app"]
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}

