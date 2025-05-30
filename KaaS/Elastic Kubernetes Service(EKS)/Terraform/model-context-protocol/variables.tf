variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "eks_version" {
  description = "EKS Cluster version"
  type        = string
  default     = "1.29"
}