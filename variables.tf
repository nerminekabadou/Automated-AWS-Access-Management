variable "region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "iam_users_table" {
  description = "DynamoDB table name for IAM users"
  default     = "IAMUsersTable"
}

variable "access_requests_table" {
  description = "DynamoDB table name for access requests"
  default     = "AccessRequestsTable"
}

variable "cleanup_lambda_name" {
  description = "Name for the cleanup Lambda function"
  default     = "iam-cleanup-lambda"
}

variable "cleanup_schedule_lambda_name" {
  description = "Name for the scheduler Lambda function"
  default     = "iam-cleanup-scheduler"
}

variable "admin_action_lambda_name" {
  description = "Name for the admin action Lambda function"
  default     = "iam-admin-action"
}

variable "admin_email" {
  description = "Admin email for notifications"
  type        = string
}

variable "from_email" {
  description = "Verified SES email address"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression"
  default     = "rate(1 day)"
}