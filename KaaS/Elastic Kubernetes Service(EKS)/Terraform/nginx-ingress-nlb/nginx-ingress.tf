
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress-helm"
  chart      = "oci://ghcr.io/nginx/charts/nginx-ingress"
  version    = "2.0.1"

  namespace       = "nginx-ingress"
  create_namespace = true
  
}