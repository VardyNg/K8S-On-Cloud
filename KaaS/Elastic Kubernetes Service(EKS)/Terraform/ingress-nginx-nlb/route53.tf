resource "aws_route53_zone" "private_zone" {
  name = var.ingress-domain
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  comment = "Private hosted zone for example.com"
}

