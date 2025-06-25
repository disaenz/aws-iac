resource "aws_ecr_repository" "grant_api" {
  name = "grant-api"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}