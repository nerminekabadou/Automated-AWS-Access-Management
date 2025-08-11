output "invoke_url" {
  description = "Full invoke URL for the decision endpoint"
  value       = "${aws_apigatewayv2_api.admin_api.api_endpoint}/${aws_apigatewayv2_stage.default.name}/decision"
}