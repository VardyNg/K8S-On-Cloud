variable "region" {
  type = string
}

variable "ingress-domain" { 
  description = "ingress domain name"
  type = string
  default = "example.com"
}

variable "eks_version" {
  type = string
  default = "1.31"
}