variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "my-api"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
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
