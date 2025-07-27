output "template_submission_lambda_name" {
  value = aws_lambda_function.template_submission_lambda.function_name
}

output "provisioning_lambda_name" {
  value = aws_lambda_function.provisioning_lambda.function_name
}

output "api_gateway_endpoint" {
  value = "https://${aws_api_gateway_rest_api.admin_api.id}.execute-api.${var.aws_region}.amazonaws.com/prod/submit-template"
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.provisioning_workflow.arn
}