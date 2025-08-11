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