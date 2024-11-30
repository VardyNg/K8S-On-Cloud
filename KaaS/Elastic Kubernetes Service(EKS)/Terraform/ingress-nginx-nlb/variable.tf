variable "region" {
  type = string
}

variable "ingress-host" { 
  type = string
}

variable "eks_version" {
  type = string
  default = "1.31"
}