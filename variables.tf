variable "lambda_s3_bucket" {
  description = "S3 bucket containing Lambda code"
  type        = string
}

variable "template_submission_lambda_key" {
  description = "S3 key for TemplateSubmissionLambda zip"
  type        = string
}

variable "provisioning_lambda_key" {
  description = "S3 key for ProvisioningLambda zip"
  type        = string
}

variable "dynamodb_access_request_table" {
  description = "DynamoDB table name for access requests"
  type        = string
}

variable "dynamodb_iam_users_table" {
  description = "DynamoDB table name for IAM users"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}