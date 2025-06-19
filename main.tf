provider "aws" {
  region = "us-east-2"
}

# Provider alias for ACM lookups in us-east-1 (for CloudFront certificates)
provider "aws" {
  alias  = "acm_east1"
  region = "us-east-1"
}

#---------------------------------
# 1. S3 Bucket (Private)
#---------------------------------
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
  # No public ACLs; CloudFront OAI will fetch objects
}

#---------------------------------
# 2. Enforce Block Public Access
#---------------------------------
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#---------------------------------
# 3. Static Website Hosting
#---------------------------------
resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

#---------------------------------
# 4. CloudFront OAI
#---------------------------------
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Origin Access Identity for portfolio site"
}

#---------------------------------
# 5. Bucket Policy: OAI only
#---------------------------------
data "aws_iam_policy_document" "oai_policy" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"
    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.oai.s3_canonical_user_id]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_site.arn}/*"]
  }
}
resource "aws_s3_bucket_policy" "static_site_policy" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.oai_policy.json

  lifecycle {
    ignore_changes = [
      # Ignore updates to the Principal section of the policy JSON
      policy,
    ]
  }
}

#---------------------------------
# 6. ACM Certificate lookup
#---------------------------------
data "aws_acm_certificate" "cert" {
  provider    = aws.acm_east1
  domain      = "daniel-saenz.com"
  statuses    = ["ISSUED"]
  most_recent = true
}

#---------------------------------
# 7. CloudFront Distribution
#---------------------------------
resource "aws_cloudfront_distribution" "static_site" {
  enabled             = true
  comment             = "Static portfolio site"
  default_root_object = "index.html"

  aliases = [
    "daniel-saenz.com",
    "www.daniel-saenz.com",
  ]

  origin {
    origin_id   = "S3StaticSite"
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3StaticSite"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = {
    Environment = "production"
    Project     = "portfolio-site"
  }
}

#---------------------------------
# 8. Route53 DNS Records
#---------------------------------
data "aws_route53_zone" "primary" {
  name         = "daniel-saenz.com."
  private_zone = false
}

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

#---------------------------------
# 9. Outputs
#---------------------------------
output "website_endpoint" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain"
  value       = aws_cloudfront_distribution.static_site.domain_name
}
