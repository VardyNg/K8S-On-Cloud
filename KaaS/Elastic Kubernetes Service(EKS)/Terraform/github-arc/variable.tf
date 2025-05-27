variable "region" {
  type    = string
  default = "us-west-2"
}

variable "eks_version" {
  type    = string
  default = "1.31"
}

variable "tags" {
	type    = map(string)
	default = {}
}

variable "github_app_id" {
	type    = string
	default = ""
}

variable "github_app_installation_id" {
	type    = string
	default = ""
}

variable "github_app_private_key" {
	type    = string
	default = ""
}

variable "github_config_url" {
	type    = string
}