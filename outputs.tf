output "decision_url" {
  description = "Endpoint opened by the links in the admin email"
  value       = module.api_gateway.invoke_url
}

output "users_table" {
  description = "DynamoDB table to register IAM users and their end_date in"
  value       = module.dynamodb.users_table_name
}
