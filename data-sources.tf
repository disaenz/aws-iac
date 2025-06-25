# ACM cert for us-east-1 (CloudFront only reads from us-east-1)
data "aws_acm_certificate" "cert" {
  provider    = aws.east1
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# Route53 hosted zone for your root domain
data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}."
  private_zone = false
}


# Lookup existing cert in us-east-1 by domain name
data "aws_acm_certificate" "api" {
  provider    = aws.east1
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}