resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  create_namespace = true 

  values = [templatefile("${path.module}/ingress-nginx.values.yaml", {
    subnetA = module.vpc.public_subnets.0,
    subnetB = module.vpc.public_subnets.1,
    subnetC = module.vpc.public_subnets.2,
  })]
}