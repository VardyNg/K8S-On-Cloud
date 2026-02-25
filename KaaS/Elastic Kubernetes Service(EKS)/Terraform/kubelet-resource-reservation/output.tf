output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = aws_eks_cluster.this.version
}

output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.resource_reservation.arn
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = aws_eks_node_group.resource_reservation.status
}

output "resource_reservation_config" {
  description = "Summary of resource reservation configuration"
  value = {
    system_reserved = {
      cpu     = var.system_reserved_cpu
      memory  = var.system_reserved_memory
      storage = var.system_reserved_storage
    }
    kube_reserved = {
      cpu     = var.kube_reserved_cpu
      memory  = var.kube_reserved_memory
      storage = var.kube_reserved_storage
    }
    eviction_thresholds = {
      hard_memory       = var.eviction_hard_memory
      hard_storage      = var.eviction_hard_storage
      soft_memory       = var.eviction_soft_memory
      soft_storage      = var.eviction_soft_storage
      soft_grace_period = var.eviction_soft_grace_period
    }
  }
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name}"
}