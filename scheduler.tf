resource "aws_iam_role" "portfolio_knowledge_refresh_scheduler" {
  name = "portfolio-knowledge-refresh-scheduler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "scheduler.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "portfolio_knowledge_refresh_scheduler_invoke" {
  name = "invoke-portfolio-knowledge-refresh"
  role = aws_iam_role.portfolio_knowledge_refresh_scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = aws_lambda_function.portfolio_knowledge_refresh.arn
    }]
  })
}

# 8:00 AM America/Denver every day. The worker exits before calling OpenAI when
# the site and resume source hash has not changed.
resource "aws_scheduler_schedule" "portfolio_knowledge_refresh_daily" {
  name                         = "portfolio-knowledge-refresh-daily"
  description                  = "Refresh portfolio AI knowledge from the public site and resume"
  schedule_expression          = "cron(0 8 * * ? *)"
  schedule_expression_timezone = "America/Denver"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.portfolio_knowledge_refresh.arn
    role_arn = aws_iam_role.portfolio_knowledge_refresh_scheduler.arn
    input = jsonencode({
      source = "portfolio.knowledge-refresh"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 2
    }
  }
}
