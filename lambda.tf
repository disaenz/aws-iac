# ============================
# --- Portfolio API Lambda
# ============================

data "aws_ecr_repository" "portfolio_api" {
  name = aws_ecr_repository.portfolio_api.name
}

locals {
  portfolio_api_environment = {
    DATABASE_URL       = var.database_url
    OPENAI_API_KEY     = var.openai_api_key
    OPENAI_MODEL       = var.openai_model
    PORTFOLIO_SITE_URL = var.portfolio_site_url
    SES_SENDER_EMAIL   = "noreply@${var.domain_name}"
    SES_REGION         = var.aws_region
    RECIPIENT_EMAIL    = var.recipient_email
  }
}

resource "aws_lambda_function" "portfolio_api" {
  function_name = "portfolio-api"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.portfolio_api.repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn

  memory_size = 512
  timeout     = 30

  environment {
    variables = local.portfolio_api_environment
  }
}

# Uses the same ECR image as the API, but starts refresh_handler.handler instead
# of the FastAPI/Mangum handler. This keeps scheduled work off the public API.
resource "aws_lambda_function" "portfolio_knowledge_refresh" {
  function_name = "portfolio-knowledge-refresh"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.portfolio_api.repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn

  memory_size = 1024
  timeout     = 300

  image_config {
    command = ["refresh_handler.handler"]
  }

  environment {
    variables = local.portfolio_api_environment
  }
}

# =======================================
# IAM Role Attachment: SES Email Permissions
# =======================================
resource "aws_iam_role_policy_attachment" "lambda_ses_permissions" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ses_email_policy.arn
}
