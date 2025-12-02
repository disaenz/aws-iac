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

# Existing Grant API ECR variable (Legacy)
variable "ecr_api_repository_name" {
  description = "Generic ECR repo for grant-api service"
  type        = string
  default     = "grant-api"
}

# New Portfolio API ECR variable (Future Migration Target)
variable "ecr_portfolio_repository_name" {
  description = "Generic ECR repo for portfolio-api service"
  type        = string
  default     = "portfolio-api"
}

# Existing Legacy Grant API image URI variable
variable "grant_api_image_uri" {
  description = "Grant API image URI in public ECR"
  type        = string
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
