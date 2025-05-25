variable "region" {
  type = string
  default = "us-west-2"
}

variable "eks_version" {
  type = string
  default = "1.31"
}

variable "arc_namespace" {
  type        = string
  default     = "arc-systems"
  description = "Kubernetes namespace for ARC controller"
}

variable "arc_runners_namespace" {
  type        = string
  default     = "arc-runners"
  description = "Kubernetes namespace for ARC runners"
}

variable "github_config_url" {
  type        = string
  default     = "https://github.com/OWNER/REPO"
  description = "GitHub URL for runner configuration (e.g., https://github.com/org/repo)"
}