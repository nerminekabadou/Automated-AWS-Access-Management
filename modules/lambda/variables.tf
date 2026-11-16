variable "region" {
  description = "AWS region"
  type        = string
}

variable "iam_users_table" {
  description = "DynamoDB table tracking IAM users"
  type        = string
}

variable "cleanup_lambda_name" {
  type = string
}

variable "cleanup_schedule_lambda_name" {
  type = string
}

variable "admin_action_lambda_name" {
  type = string
}

variable "admin_email" {
  description = "Admin address that receives the cleanup emails"
  type        = string
}

variable "from_email" {
  description = "SES-verified sender address"
  type        = string
}

variable "admin_decision_url" {
  description = "URL of the decision endpoint used in the email links"
  type        = string
}

variable "ses_template_name" {
  description = "SES template used for the admin email"
  type        = string
}

variable "decision_secret" {
  description = "Secret used to sign decision links"
  type        = string
  sensitive   = true
}

variable "link_ttl_hours" {
  description = "Validity of the decision links, in hours"
  type        = number
}
