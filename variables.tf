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

variable "ecr_repository_name" {
  description = "Generic ECR repo for all portfolio services"
  type        = string
  default     = "portfolio-services"
}