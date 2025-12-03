# ============================
# --- Portfolio API Logs
# ============================
resource "aws_cloudwatch_log_group" "portfolio_api" {
  name              = "/aws/lambda/${aws_lambda_function.portfolio_api.function_name}"
  retention_in_days = 3
}