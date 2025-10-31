data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}
resource "random_id" "random_string" {
  byte_length = 2
}
locals {
  name   = lower("${basename(path.cwd)}-${substr(base64encode(random_id.random_string.b64_url), 0, 3)}")
  region = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    project = local.name
  }
}