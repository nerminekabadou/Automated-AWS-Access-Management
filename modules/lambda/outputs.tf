output "access_request_function_arn" {
  description = "ARN of the access request Lambda function"
  value       = aws_lambda_function.access_request.arn
}

output "access_request_function_name" {
  description = "Name of the access request Lambda function"
  value       = aws_lambda_function.access_request.function_name
}

output "approval_function_arn" {
  description = "ARN of the approval Lambda function"
  value       = aws_lambda_function.approval.arn
}

output "approval_function_name" {
  description = "Name of the approval Lambda function"
  value       = aws_lambda_function.approval.function_name
}