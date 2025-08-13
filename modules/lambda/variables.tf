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

