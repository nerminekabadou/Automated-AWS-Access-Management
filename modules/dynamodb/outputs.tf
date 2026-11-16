output "users_table_name" {
  value = aws_dynamodb_table.iam_users.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.iam_users.arn
}
