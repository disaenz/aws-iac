# ============================
# --- Existing Grant API ECR (Legacy)
# ============================
resource "aws_ecr_repository" "grant_api" {
  name = var.ecr_api_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
  # NOTE: force_delete is only safe while repo is empty.
  force_delete = true
}

resource "aws_ecr_repository_policy" "grant_api_lambda_pull" {
  repository = aws_ecr_repository.grant_api.name

  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid = "AllowLambdaPull",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid = "AllowAccountPushPull",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# ============================
# --- NEW Portfolio API ECR
# ============================
resource "aws_ecr_repository" "portfolio_api" {
  name = var.ecr_portfolio_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "aws_ecr_repository_policy" "portfolio_api_lambda_pull" {
  repository = aws_ecr_repository.portfolio_api.name

  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid = "AllowLambdaPull",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      },
      {
        Sid = "AllowAccountPushPull",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}
