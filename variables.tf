variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "iam_users_table" {
  description = "DynamoDB table tracking IAM users and their access end date"
  type        = string
  default     = "IAMUsersTable"
}

variable "cleanup_lambda_name" {
  description = "Name of the Lambda that disables or deletes a user"
  type        = string
  default     = "iam-cleanup-lambda"
}

variable "cleanup_schedule_lambda_name" {
  description = "Name of the daily scheduler Lambda"
  type        = string
  default     = "iam-cleanup-scheduler"
}

variable "admin_action_lambda_name" {
  description = "Name of the Lambda behind the decision endpoint"
  type        = string
  default     = "iam-admin-action"
}

variable "admin_email" {
  description = "Admin address that receives the cleanup emails"
  type        = string
}

variable "from_email" {
  description = "SES-verified sender address"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule for the expiry check"
  type        = string
  default     = "rate(1 day)"
}

variable "link_ttl_hours" {
  description = "How long the decision links in the email stay valid"
  type        = number
  default     = 24
}
