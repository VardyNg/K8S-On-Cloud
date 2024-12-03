resource "kubernetes_namespace" "eks_sample_app" {
  metadata {
    name = "eks-sample-app"
  }
}

resource "kubernetes_deployment" "eks_sample_windows_deployment" {
  metadata {
    name      = "eks-sample-windows-deployment"
    namespace = kubernetes_namespace.eks_sample_app.metadata[0].name
    labels = {
      app = "eks-sample-windows-app"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "eks-sample-windows-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "eks-sample-windows-app"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "beta.kubernetes.io/arch"
                  operator = "In"
                  values   = ["amd64"]
                }
              }
            }
          }
        }

        container {
          name  = "windows-server-iis"
          image = "mcr.microsoft.com/windows/servercore:ltsc2022"

          port {
            name           = "http"
            container_port = 80
          }

          image_pull_policy = "IfNotPresent"

          command = [
            "powershell.exe",
            "-command",
            "Add-WindowsFeature Web-Server; Invoke-WebRequest -UseBasicParsing -Uri 'https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe' -OutFile 'C:\\ServiceMonitor.exe'; echo '<html><body><br/><br/><marquee><H1>Hello EKS!!!<H1><marquee></body><html>' > C:\\inetpub\\wwwroot\\default.html; C:\\ServiceMonitor.exe 'w3svc';"
          ]
        }

        node_selector = {
          "kubernetes.io/os" = "windows"
        }
      }
    }
  }
}