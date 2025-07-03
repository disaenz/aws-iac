# ACM cert for us-east-1 (CloudFront only reads from us-east-1)
data "aws_acm_certificate" "cert" {
  provider    = aws.east1
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# ACM cert wildcard for us-east-1 (CloudFront only reads from us-east-1)
data "aws_acm_certificate" "cert" {
  provider    = aws.east1  
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}

# Route53 hosted zone for your root domain
data "aws_route53_zone" "primary" {
  name         = "${var.domain_name}."
  private_zone = false
}

# AWS account identity (for ECR repo policies etc.)
data "aws_caller_identity" "current" {}