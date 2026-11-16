variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "api_gateway_url" {
  description = "The URL of the API Gateway"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID from api_gateway module"
  type        = string
}


variable "lambda_exec_role_arn" {
  description = "ARN of the existing IAM role the Lambda functions run with"
  type        = string
}

variable "admin_email" {
  description = "Email address that receives access approval and review requests"
  type        = string
}

variable "sender_email" {
  description = "SES-verified email address used as the sender"
  type        = string
}
