# --- Origin Access Identity (OAI) - reuse for both sites ---
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Origin Access Identity for static sites"
}

# --- Main Portfolio Site Distribution (existing, for reference) ---
resource "aws_cloudfront_distribution" "static_site" {
  enabled             = true
  comment             = "Static portfolio site"
  default_root_object = "index.html"

  aliases = [
    var.domain_name,
    "www.${var.domain_name}",
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

# --- CloudFront Distribution for Grant App ---
resource "aws_cloudfront_distribution" "grant_app" {
  enabled             = true
  comment             = "Grant App React frontend"
  default_root_object = "index.html"

  aliases = [
    "grants.${var.domain_name}"
  ]

  origin {
    origin_id   = "S3GrantApp"
    domain_name = aws_s3_bucket.grant_app_site.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3GrantApp"
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
    acm_certificate_arn      = data.aws_acm_certificate.wildcard_us_east_1.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = {
    Environment = "production"
    Project     = "grant-app"
  }
}