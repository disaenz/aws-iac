# --- API Lambda ---
data "aws_ecr_repository" "grant_api" {
  name = aws_ecr_repository.grant_api.name
}

resource "aws_lambda_function" "grant_api" {
  function_name = "grant-api"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.grant_api.repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn

  memory_size   = 128
  timeout       = 10

  environment {
    variables = {
      DATABASE_URL = var.database_url
    }
  }
}