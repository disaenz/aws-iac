# ============================
# --- Portfolio API Lambda
# ============================

data "aws_ecr_repository" "portfolio_api" {
  name = aws_ecr_repository.portfolio_api.name
}

resource "aws_lambda_function" "portfolio_api" {
  function_name = "portfolio-api"
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.portfolio_api.repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn

  memory_size   = 512
  timeout       = 30

  environment {
    variables = {
      DATABASE_URL    = var.database_url
      OPENAI_API_KEY  = var.openai_api_key
      SES_SENDER_EMAIL = "noreply@${var.domain_name}"
      SES_REGION       = var.aws_region
    }
  }
}

# =======================================
# IAM Role Attachment: SES Email Permissions
# =======================================
resource "aws_iam_role_policy_attachment" "lambda_ses_permissions" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ses_email_policy.arn
}