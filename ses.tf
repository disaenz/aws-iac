########################################
# SES Domain Identity (same as Route 53 domain)
########################################
resource "aws_ses_domain_identity" "portfolio" {
  domain = var.domain_name
}

########################################
# SES DKIM Signing - improves deliverability & trust
########################################
resource "aws_ses_domain_dkim" "portfolio" {
  domain = aws_ses_domain_identity.portfolio.domain
}

########################################
# TXT Record for SES Domain Verification
########################################
resource "aws_route53_record" "ses_verification" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = 300
  records = [aws_ses_domain_identity.portfolio.verification_token]
}

########################################
# SES DKIM CNAME Records (3 required)
########################################
resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${aws_ses_domain_dkim.portfolio.dkim_tokens[count.index]}._domainkey.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [
    "${aws_ses_domain_dkim.portfolio.dkim_tokens[count.index]}.dkim.amazonses.com"
  ]
}

########################################
# Verified Sender Email Identity
########################################
resource "aws_ses_email_identity" "noreply" {
  email = "noreply@${var.domain_name}"
}

########################################
# IAM Policy for Lambda Email Send Permissions
########################################
resource "aws_iam_policy" "ses_email_policy" {
  name        = "portfolio-api-ses-policy"
  description = "Allow Lambda to send emails via SES"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*"
      }
    ]
  })
}

########################################
# Outputs
########################################
output "ses_verified_email" {
  description = "The verified noreply email identity"
  value       = aws_ses_email_identity.noreply.email
}

output "ses_domain_arn" {
  description = "SES Domain Identity ARN"
  value       = aws_ses_domain_identity.portfolio.arn
}