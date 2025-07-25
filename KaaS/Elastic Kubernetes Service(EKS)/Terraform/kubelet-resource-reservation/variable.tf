variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "kubelet-resource-reservation"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "system_reserved_cpu" {
  description = "CPU resources reserved for system processes (in millicores)"
  type        = string
  default     = "100m"
}

variable "system_reserved_memory" {
  description = "Memory resources reserved for system processes"
  type        = string
  default     = "256Mi"
}

variable "system_reserved_storage" {
  description = "Storage resources reserved for system processes"
  type        = string
  default     = "1Gi"
}

variable "kube_reserved_cpu" {
  description = "CPU resources reserved for Kubernetes components (in millicores)"
  type        = string
  default     = "100m"
}

variable "kube_reserved_memory" {
  description = "Memory resources reserved for Kubernetes components"
  type        = string
  default     = "256Mi"
}

variable "kube_reserved_storage" {
  description = "Storage resources reserved for Kubernetes components"
  type        = string
  default     = "1Gi"
}

variable "eviction_hard_memory" {
  description = "Hard eviction threshold for available memory"
  type        = string
  default     = "100Mi"
}

variable "eviction_hard_storage" {
  description = "Hard eviction threshold for available node filesystem"
  type        = string
  default     = "10%"
}

variable "eviction_soft_memory" {
  description = "Soft eviction threshold for available memory"
  type        = string
  default     = "200Mi"
}

variable "eviction_soft_storage" {
  description = "Soft eviction threshold for available node filesystem"
  type        = string
  default     = "15%"
}

variable "eviction_soft_grace_period" {
  description = "Grace period for soft eviction"
  type        = string
  default     = "30s"
}