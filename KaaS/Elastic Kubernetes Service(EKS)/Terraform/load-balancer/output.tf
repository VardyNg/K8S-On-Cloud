output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "nlb-by-service-dns-name" {
  description = "NLB DNS name"
  value       = kubernetes_service_v1.nlb-by-service.status[0].load_balancer[0].ingress[0].hostname
}

output "nlb-with-target-group-dns-name" {
  description = "NLB DNS name"
  value       = aws_lb.nlb.dns_name
}

output "alb-by-ingress-dns-name" {
  description = "ALB DNS name"
  value       = kubernetes_ingress_v1.alb-by-ingress.status[0].load_balancer[0].ingress[0].hostname
}

output "alb-with-group-dns-name" {
  description = "ALB DNS name"
  value       = kubernetes_ingress_v1.alb-ingress-group-member-1.status[0].load_balancer[0].ingress[0].hostname
}