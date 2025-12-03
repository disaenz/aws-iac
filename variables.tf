variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "domain_name" {
  description = "The custom domain for the site"
  type        = string
}

variable "aws_region" {
  description = "AWS default region to use"
  type        = string
}

variable "ecr_portfolio_repository_name" {
  description = "Portfolio API ECR repository name"
  type        = string
  default     = "portfolio-api"
}

variable "database_url" {
  description = "NeonDB connection string"
  type        = string
  sensitive   = true
}

variable "grant_app_bucket_name" {
  description = "S3 bucket name for the Grant App frontend"
  type        = string
}