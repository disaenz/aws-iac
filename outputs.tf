output "website_endpoint" {
  description = "S3 static website endpoint"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain"
  value       = aws_cloudfront_distribution.static_site.domain_name
}

output "portfolio_knowledge_refresh_function_name" {
  description = "Lambda function invoked by the daily portfolio knowledge schedule"
  value       = aws_lambda_function.portfolio_knowledge_refresh.function_name
}
