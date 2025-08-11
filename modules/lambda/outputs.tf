# IAM Role Outputs
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  value       = aws_iam_role.lambda_execution_role.arn
}

# Lambda Function ARNs
output "cleanup_lambda_arn" {
  description = "ARN of the cleanup Lambda function"
  value       = aws_lambda_function.cleanup_lambda.arn
}

output "cleanup_scheduler_lambda_arn" {
  description = "ARN of the scheduler Lambda function"
  value       = aws_lambda_function.cleanup_scheduler_lambda.arn
}

output "admin_action_lambda_arn" {
  description = "ARN of the admin action Lambda function"
  value       = aws_lambda_function.admin_action_lambda.arn
}

# Lambda Function Names
output "cleanup_lambda_name" {
  description = "Name of the cleanup Lambda function"
  value       = aws_lambda_function.cleanup_lambda.function_name
}

output "cleanup_scheduler_lambda_name" {
  description = "Name of the scheduler Lambda function"
  value       = aws_lambda_function.cleanup_scheduler_lambda.function_name
}

output "admin_action_lambda_name" {
  description = "Name of the admin action Lambda function"
  value       = aws_lambda_function.admin_action_lambda.function_name
}

# Lambda Function Invoke ARNs
output "cleanup_lambda_invoke_arn" {
  description = "Invoke ARN of the cleanup Lambda function"
  value       = aws_lambda_function.cleanup_lambda.invoke_arn
}

output "cleanup_scheduler_lambda_invoke_arn" {
  description = "Invoke ARN of the scheduler Lambda function"
  value       = aws_lambda_function.cleanup_scheduler_lambda.invoke_arn
}

output "admin_action_lambda_invoke_arn" {
  description = "Invoke ARN of the admin action Lambda function"
  value       = aws_lambda_function.admin_action_lambda.invoke_arn
}