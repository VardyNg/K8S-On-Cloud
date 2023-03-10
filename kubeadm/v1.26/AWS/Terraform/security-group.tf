// https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
module "sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "${var.project_name}-sg"
  description = "Security group for SSH access"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = [
    "0.0.0.0/0"
  ]
}