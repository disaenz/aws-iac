provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
}

