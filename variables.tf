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

variable "openai_api_key" {
  description = "OpenAI API Key for Portfolio Chatbot"
  type        = string
  sensitive   = true
}

variable "openai_model" {
  description = "OpenAI model used by the portfolio chat and knowledge refresh"
  type        = string
  default     = "gpt-4o-mini"
}

variable "portfolio_site_url" {
  description = "Deployed portfolio site used by the scheduled knowledge refresh"
  type        = string
  default     = "https://daniel-saenz.com"
}

variable "grant_app_bucket_name" {
  description = "S3 bucket name for the Grant App frontend"
  type        = string
}

variable "recipient_email" {
  description = "The email address for recipients of portfolio emails"
  type        = string
}
