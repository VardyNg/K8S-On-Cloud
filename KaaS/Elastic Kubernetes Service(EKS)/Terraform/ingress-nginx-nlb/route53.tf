resource "aws_route53_zone" "private_zone" {
  name = var.ingress-domain
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  comment = "Private hosted zone for example.com"
}

resource "aws_route53_record" "nginx_cname_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "nginx"
  type    = "CNAME"
  ttl     = 300
  records = ["placeholder.com"]
}

resource "aws_route53_record" "apache_cname_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "apache"
  type    = "CNAME"
  ttl     = 300
  records = ["placeholder.com"]
}