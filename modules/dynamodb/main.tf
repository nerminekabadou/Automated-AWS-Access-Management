# One item per temporary IAM user:
# { username, end_date (YYYY-MM-DD), status: active | pending_action | disabled | deleted }
resource "aws_dynamodb_table" "iam_users" {
  name         = var.iam_users_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"

  attribute {
    name = "username"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}
