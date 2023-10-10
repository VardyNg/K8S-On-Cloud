variable "app_name" {
  description = "The name of the application"
  type        = string 
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
}

variable "node_vm_size" {
  description = "value of the VM size"
  type        = string
}

variable "node_count" {
  description = "value of the node count"
  type        = number
}