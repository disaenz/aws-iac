# ============================
# --- Backend API Gateway (shared)
# ============================
resource "aws_apigatewayv2_api" "http_api" {
  name          = "grant-api-http"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST", "PATCH", "OPTIONS"]
    allow_headers     = ["*"]
    max_age           = 3600
    allow_credentials = false
  }
}

# ============================
# --- Legacy Lambda Integration (Grant API)
# ============================
resource "aws_apigatewayv2_integration" "grant_api_lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.grant_api.invoke_arn
  payload_format_version = "2.0"
}

# ============================
# --- New Lambda Integration (Portfolio API)
# ============================
resource "aws_apigatewayv2_integration" "portfolio_api_lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.portfolio_api.invoke_arn
  payload_format_version = "2.0"
}

# ============================
# --- Route (Still pointing to Legacy Lambda)
# ============================
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  # ⚠️ Still pointing to old Lambda for now!
  target    = "integrations/${aws_apigatewayv2_integration.grant_api_lambda.id}"
}

# ============================
# --- Default Stage Deployment
# ============================
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# ============================
# --- Permissions (Invoke)
# ============================
# Legacy Lambda permission
resource "aws_lambda_permission" "allow_apigw_grant_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grant_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# New Lambda permission
resource "aws_lambda_permission" "allow_apigw_portfolio_api" {
  statement_id  = "AllowAPIGatewayInvokePortfolio"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.portfolio_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
