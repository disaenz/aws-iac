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
    acm_certificate_arn      = aws_acm_certificate_validation.api.certificate_arn
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

# --- Grant App S3 Bucket ---
resource "aws_s3_bucket" "grant_app_site" {
  bucket = "grants-app.${var.domain_name}"
}

resource "aws_s3_bucket_public_access_block" "grant_app_site" {
  bucket                  = aws_s3_bucket.grant_app_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "grant_app_site" {
  bucket = aws_s3_bucket.grant_app_site.id
  index_document { suffix = "index.html" }
  error_document { key    = "error.html"  }
}

data "aws_iam_policy_document" "grant_app_oai_policy" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"
    principals {
      type        = "CanonicalUser"
      identifiers = [aws_cloudfront_origin_access_identity.oai.s3_canonical_user_id]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.grant_app_site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "grant_app_site_policy" {
  bucket = aws_s3_bucket.grant_app_site.id
  policy = data.aws_iam_policy_document.grant_app_oai_policy.json

  lifecycle {
    ignore_changes = [policy]
  }
}

# --- CloudFront Distribution for Grant App ---
resource "aws_cloudfront_distribution" "grant_app" {
  enabled             = true
  comment             = "Grant App React frontend"
  default_root_object = "index.html"

  aliases = [
    "grants-app.${var.domain_name}"
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
    acm_certificate_arn      = aws_acm_certificate_validation.api.certificate_arn
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