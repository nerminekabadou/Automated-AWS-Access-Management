resource "aws_dynamodb_table" "access_requests" {
  name         = "AccessRequestsTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "request_id"

  attribute {
    name = "request_id"
    type = "S"
  }

  # Add any additional attributes you need for queries
  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Environment = "prod"
  }

  global_secondary_index {
    name            = "UserIndex"
    hash_key        = "user_id"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "policy_templates" {
  name         = "PolicyTemplatesTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "resource"

  attribute {
    name = "resource"
    type = "S"
  }
}