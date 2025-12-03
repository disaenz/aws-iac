# ============================
# --- Legacy Grant API Logs (temporary)
# ============================
resource "aws_cloudwatch_log_group" "grant_api" {
  name              = "/aws/lambda/${aws_lambda_function.grant_api.function_name}"
  retention_in_days = 3
}

# ============================
# --- New Portfolio API Logs
# ============================
resource "aws_cloudwatch_log_group" "portfolio_api" {
  name              = "/aws/lambda/${aws_lambda_function.portfolio_api.function_name}"
  retention_in_days = 3
}
