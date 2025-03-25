variable "region" {
  type = string
}

variable "ingress-host" { 
  description = "value of the host field in the ingress resource"
  type = string
  default = "test.example.com"
}

variable "eks_version" {
  type = string
  default = "1.31"
}