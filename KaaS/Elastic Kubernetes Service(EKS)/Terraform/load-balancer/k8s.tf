
# resource "kubernetes_namespace" "sample-app" {
#   metadata {
#     name = "sample-app"
#   }
# }

# resource "kubernetes_deployment" "nginx" {
#   metadata {
#     name = "nginx-deployment"
#     labels = {
#       app = "nginx"
#     }
#   }

#   spec {
#     replicas = 5
#     selector {
#       match_labels = {
#         app = "nginx"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "nginx"
#         }
#       }

#       spec {
#         container {
#           image = "nginx:latest"
#           name  = "nginx"
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }
