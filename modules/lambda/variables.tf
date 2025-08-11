variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "iam_users_table" {
  description = "DynamoDB table name for IAM users"
  type        = string
  default     = "IAMUsersTable"
}

variable "access_requests_table" {
  description = "DynamoDB table name for access requests"
  type        = string
  default     = "AccessRequestsTable"
}

variable "cleanup_lambda_name" {
  description = "Name for the cleanup Lambda function"
  type        = string
  default     = "iam-cleanup-lambda"
}

variable "cleanup_schedule_lambda_name" {
  description = "Name for the scheduler Lambda function"
  type        = string
  default     = "iam-cleanup-scheduler"
}

variable "admin_action_lambda_name" {
  description = "Name for the admin action Lambda function"
  type        = string
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

variable "admin_decision_url" {
  description = "API Gateway endpoint for admin decisions"
  type        = string
}

variable "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule that triggers the scheduler"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for permissions"
  type        = string
}