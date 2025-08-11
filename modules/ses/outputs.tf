output "from_email_identity_arn" {
  description = "ARN of the verified SES sender identity"
  value       = aws_ses_email_identity.sender.arn
}

output "template_name" {
  description = "Name of the SES template for admin notifications"
  value       = aws_ses_template.admin_notification.name
}

