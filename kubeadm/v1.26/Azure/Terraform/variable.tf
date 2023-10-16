variable "app_name" {
  description = "The name of the application"
  type        = string 
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
}

variable "node_count" {
  description = "The number of nodes to create in the cluster."
  type        = number
}

variable "location_max_az" {
  description = "The maximum availability zone index in the location."
  type        = number
  default     = 3
}

variable "vm_admin_username" {
  description = "value of the admin username for the VMs"
  type        = string
}

variable "vm_admin_password" {
  description = "value of the admin password for the VMs"
  type        = string
}

