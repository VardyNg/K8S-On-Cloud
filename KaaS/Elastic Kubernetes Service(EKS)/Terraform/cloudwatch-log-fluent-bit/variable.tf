variable "fluent_bit_http_port" {
  default = "2020"
}

variable "fluent_bit_read_from_head" {
  default = "Off"
}

variable "eks_version" {
  type    = string
  default = "1.31"
}

variable "region" {
  type = string
}
