resource "aws_acm_certificate" "ingress-1" {
  domain_name       = var.domain_1
  validation_method = "DNS"
}

resource "aws_acm_certificate" "ingress-2" {
  domain_name       = var.domain_2
  validation_method = "EMAIL"
}