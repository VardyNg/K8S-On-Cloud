variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "subnet_az_list" {
  description = "The list of availability zones to use for the subnets"
  type        = list(string)
}