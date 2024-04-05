

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}
data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}
data "template_cloudinit_config" "node" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/user_data/cloud-init.tftpl")
  }
  part {
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/user_data/node-config.tftpl", local.template_vars)
  }

}
locals {
  name   = basename(path.cwd)
  region = "us-west-2"
  cluster_version = "1.29"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    project  = local.name
  }
  policy_vars = {
    Region       = local.region,
    Account      = data.aws_caller_identity.current.account_id
    Partition    = data.aws_partition.current.partition
    ClusterName  = module.eks.cluster_name
    UrlSuffix    = data.aws_partition.current.dns_suffix
    OidcProvider = module.eks.oidc_provider
  }
  template_vars = {
    cluster_name                           = module.eks.cluster_name
    cluster_endpoint                       = module.eks.cluster_endpoint
    cluster_certificate_authority          = module.eks.cluster_certificate_authority_data
    outbound_proxy_url                     = ""
    no_proxy_endpoints                     = join(",", [for k, v in module.vpc_endpoints.endpoints : v.service_name])
    pause_container_account_id             = data.aws_partition.current.partition == "aws" ? "aws" : lookup(local.pause_container_account_id, data.aws_partition.current.partition)
    amazon_ssm_agent_url                   = lookup(local.ssm_agent, data.aws_partition.current.partition)
    kubelet_extra_args                     = ""
    enable_cloudwatch_agent                = false
    cloudwatch_agent_config_parameter_name = ""
  }
  ssm_agent = {
    aws     = "https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_amd64/amazon-ssm-agent.rpm"
    aws-iso = "https://s3.us-iso-east-1.c2s.ic.gov/amazon-ssm-us-iso-east-1/latest/linux_amd64/amazon-ssm-agent.rpm"
  }
  pause_container_account_id = {
    aws-iso = "725322719131"
  }
}