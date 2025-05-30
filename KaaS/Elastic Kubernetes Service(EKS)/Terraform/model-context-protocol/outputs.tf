output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "mcp_server_role_arn" {
  description = "ARN of the IAM role for MCP server"
  value       = module.mcp_server_role.iam_role_arn
}

output "connect_to_mcp_server" {
  description = "Example command to use the AI client to interact with the MCP server"
  value       = "python3 examples/ai_client.py --cluster ${module.eks.cluster_name} --region ${local.region} --action get-context"
}