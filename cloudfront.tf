resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Origin Access Identity for portfolio site"
}

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