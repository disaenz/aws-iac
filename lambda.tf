resource "aws_lambda_function" "grant_api" {
  function_name = "grant-api"
  package_type  = "Image"
  image_uri     = var.grant_api_image_uri
  role          = aws_iam_role.lambda_exec.arn

  # if app is too slow, you can increase memory here
  memory_size = 128
  timeout     = 10
}