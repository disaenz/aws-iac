# --- Backend API Gateway ---
resource "aws_apigatewayv2_api" "http_api" {
  name          = "grant-api-http"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]          
    allow_methods = ["GET", "POST", "PATCH"]
    allow_headers = ["*"]          
    max_age       = 3600         
    allow_credentials = false  
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                = aws_apigatewayv2_api.http_api.id
  integration_type      = "AWS_PROXY"
  integration_uri       = aws_lambda_function.grant_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grant_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# --- Frontend API Gateway ---
resource "aws_apigatewayv2_api" "frontend_app" {
  name          = "grant-app-http"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins     = ["*"]      
    allow_methods     = ["GET"]   
    allow_headers     = ["*"]
    max_age           = 3600
    allow_credentials = false
  }
}

resource "aws_apigatewayv2_integration" "frontend_lambda" {
  api_id                  = aws_apigatewayv2_api.frontend_app.id
  integration_type        = "AWS_PROXY"
  integration_uri         = aws_lambda_function.grant_app.function_name 
  payload_format_version  = "2.0"
}

resource "aws_apigatewayv2_route" "frontend_default" {
  api_id    = aws_apigatewayv2_api.frontend_app.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.frontend_lambda.id}"
}

resource "aws_apigatewayv2_stage" "frontend_prod" {
  api_id      = aws_apigatewayv2_api.frontend_app.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "frontend_allow_apigw" {
  statement_id  = "AllowAPIGatewayInvokeFrontend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grant_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.frontend_app.execution_arn}/*/*"
}