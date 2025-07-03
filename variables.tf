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

variable "ecr_api_repository_name" {
  description = "Generic ECR repo for grant-api service"
  type        = string
  default     = "grant-api"
}

variable "grant_api_image_uri" {
  description = "Grant API image URI in public ECR"
  type        = string
}

variable "database_url" {
  description = "NeonDB connection string"
  type        = string
  sensitive   = true
}