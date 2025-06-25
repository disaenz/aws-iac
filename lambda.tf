data "aws_ecrpublic_repository" "grant_api" {
  repository_name = "grant-api"
}

resource "aws_lambda_function" "grant_api" {
  function_name = "grant-api"
  package_type  = "Image"
  image_uri     = "${data.aws_ecrpublic_repository.grant_api.repository_uri}:latest"
  role          = aws_iam_role.lambda_exec.arn

  # if app is too slow, you can increase memory here
  memory_size = 128
  timeout     = 10
}