resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id
  index_document { suffix = "index.html" }
  error_document { key    = "error.html"  }
}

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
    ignore_changes = [policy]
  }
}

#-------------------------------------TERRAFORM S3 BUCKET-------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name}-iac"

  tags = {
    Environment = "iac"
    Project     = "terraform-state"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}