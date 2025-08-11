variable "schedule_expression" {
  description = "CloudWatch Events schedule expression (e.g., 'rate(1 day)')"
  type        = string
  default     = "rate(1 day)"
  
  validation {
    condition     = can(regex("^(cron\\(|rate\\().+", var.schedule_expression))
    error_message = "Must be valid EventBridge schedule expression starting with 'cron(' or 'rate('"
  }
}

variable "cleanup_scheduler_lambda_arn" {
  description = "ARN of the cleanup scheduler Lambda function"
  type        = string
  
  validation {
    condition     = can(regex("^arn:aws:lambda:", var.cleanup_scheduler_lambda_arn))
    error_message = "Must be a valid Lambda ARN"
  }
}

variable "cleanup_scheduler_lambda_name" {
  description = "Name of the cleanup scheduler Lambda function"
  type        = string
  
  validation {
    condition     = length(var.cleanup_scheduler_lambda_name) > 0 && length(var.cleanup_scheduler_lambda_name) <= 64
    error_message = "Lambda name must be 1-64 characters"
  }
}