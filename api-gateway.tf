# ============================
# --- Backend API Gateway (shared)
# ============================
resource "aws_apigatewayv2_api" "http_api" {
  name          = "portfolio-api-http"
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
# --- Lambda Integration (Portfolio API)
# ============================
resource "aws_apigatewayv2_integration" "portfolio_api_lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.portfolio_api.invoke_arn
  payload_format_version = "2.0"
}

# ============================
# --- Default Route NOW points to Portfolio API 🎯
# ============================
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.portfolio_api_lambda.id}"
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
# --- Permissions for Portfolio API Lambda
# ============================
resource "aws_lambda_permission" "allow_apigw_portfolio_api" {
  statement_id  = "AllowAPIGatewayInvokePortfolio"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.portfolio_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}