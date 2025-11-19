variable "region" {
  type    = string
  default = "us-east-1"
}

variable "eks_version" {
  type    = string
  default = "1.34"
}

variable "tags" {
  type    = map(string)
  default = {}
}