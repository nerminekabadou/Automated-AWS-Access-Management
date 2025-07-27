variable "region" {
  description = "AWS region"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "access_request_lambda_arn" {
  description = "ARN of the access request Lambda function"
  type        = string
}

variable "approval_lambda_arn" {
  description = "ARN of the approval Lambda function"
  type        = string
}