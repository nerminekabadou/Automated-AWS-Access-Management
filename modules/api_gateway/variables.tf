variable "admin_action_lambda_arn" {
  description = "ARN of the admin action Lambda function"
  type        = string
}

variable "admin_action_lambda_name" {
  description = "Name of the admin action Lambda function"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

