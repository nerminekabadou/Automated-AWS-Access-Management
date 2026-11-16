output "invoke_url" {
  description = "Full URL of the decision endpoint (the $default stage has no path prefix)"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}decision"
}
