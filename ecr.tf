resource "aws_ecrpublic_repository" "services" {
  repository_name      = var.ecr_repository_name

  catalog_data {
    description = "Container images for portfolio services"
  }

  tags = {
    Environment = "production"
    Project     = "portfolio"
  }
}

output "ecr_public_repository_url" {
  description = "Public ECR repository URI"
  value       = aws_ecrpublic_repository.services.repository_uri
}