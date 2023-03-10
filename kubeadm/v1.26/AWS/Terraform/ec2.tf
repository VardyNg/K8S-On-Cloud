// https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  count = 3

  name = "${var.project_name}-${count.index + 1}"

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  private_ip             = "10.0.101.${count.index + 10}" # ip address start from 10.0.1.10, 10.0.1.11 ....
  user_data              = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
}