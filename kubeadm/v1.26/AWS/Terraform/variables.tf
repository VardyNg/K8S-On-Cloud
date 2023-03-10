# Project Name
variable "project_name" {
  type    = string
  default = ""
}

# VPC
variable "vpc_cidr" {
  type    = string
  default = ""
}

variable "vpc_azs" {
  type    = list(string)
  default = []
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = []
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = []
}

# EC2
variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-ebd02392"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for the EC2 instance"
  type        = string
  default     = "user1"
}
