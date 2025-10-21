output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}


output "secret_name" {
  description = "Name of the created secret"
  value       = aws_secretsmanager_secret.example_secret.name
}

output "secret_arn" {
  description = "ARN of the created secret"
  value       = aws_secretsmanager_secret.example_secret.arn
}
