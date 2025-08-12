output "invoke_url" {
  value = "https://${module.api_gateway.api_id}.execute-api.${var.region}.amazonaws.com/prod/"
}
