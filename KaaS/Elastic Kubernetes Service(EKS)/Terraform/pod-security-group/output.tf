output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "pod_security_group_id" {
	description = "The Security Group ID assigned to pods via the SecurityGroupPolicy"
	value       = kubernetes_manifest.security_group_policy.manifest["spec"]["securityGroups"]["groupIds"][0]
}