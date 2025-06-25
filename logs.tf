resource "aws_cloudwatch_log_group" "grant_api" {
  name              = "/aws/lambda/${aws_lambda_function.grant_api.function_name}"
  retention_in_days = 3
}