# --- Route53 Alias for root domain ---
resource "aws_route53_record" "root_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = data.aws_route53_zone.primary.name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_site.domain_name
    zone_id                = aws_cloudfront_distribution.static_site.hosted_zone_id
    evaluate_target_health = false
  }
}

# --- Route53 Alias for www ---
resource "aws_route53_record" "www_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.static_site.domain_name
    zone_id                = aws_cloudfront_distribution.static_site.hosted_zone_id
    evaluate_target_health = false
  }
}

# --- Route53 Alias for grants.daniel-saenz.com ---
resource "aws_route53_record" "grant_app_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "grants"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.grant_app.domain_name
    zone_id                = aws_cloudfront_distribution.grant_app.hosted_zone_id
    evaluate_target_health = false
  }
}

# --- Wildcard ACM cert for all subdomains (*.daniel-saenz.com) in us-east-2 (API Gateway) ---
resource "aws_acm_certificate" "wildcard" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "api_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
}

# --- Wildcard ACM cert for all subdomains (*.daniel-saenz.com) in us-east-1 (for CloudFront) ---
resource "aws_acm_certificate" "wildcard_us_east_1" {
  provider          = aws.east1
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "wildcard_cert_validation_us_east_1" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_us_east_1.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard_us_east_1" {
  provider                = aws.east1
  certificate_arn         = aws_acm_certificate.wildcard_us_east_1.arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_cert_validation_us_east_1 : record.fqdn]
}

# =========== API Gateway Custom Domain for API ===========
resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = "api.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.api.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api.domain_name
  stage       = aws_apigatewayv2_stage.prod.name
}

resource "aws_route53_record" "api_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "api"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}