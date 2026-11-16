# Lambda deployment packages are built from the handlers at plan time,
# so the deployed code always matches lambda_code/*.py.
data "archive_file" "access_request" {
  type        = "zip"
  source_file = "${path.root}/lambda_code/access_request_handler.py"
  output_path = "${path.root}/build/access_request.zip"
}

data "archive_file" "approval" {
  type        = "zip"
  source_file = "${path.root}/lambda_code/approval_handler.py"
  output_path = "${path.root}/build/approval.zip"
}

resource "aws_lambda_function" "access_request" {
  function_name = "access-request"
  role          = var.lambda_exec_role_arn
  handler       = "access_request_handler.access_request_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.access_request.output_path
  source_code_hash = data.archive_file.access_request.output_base64sha256

  environment {
    variables = {
      POLICY_TEMPLATES_TABLE = "PolicyTemplatesTable"
      ACCESS_REQUESTS_TABLE  = "AccessRequestsTable"
      API_GATEWAY_ID         = var.api_gateway_id
      REGION                 = var.region
      STAGE                  = "prod"
      ADMIN_EMAIL            = var.admin_email
      SENDER_EMAIL           = var.sender_email
    }
  }
}

resource "aws_lambda_function" "approval" {
  function_name = "approval"
  role          = var.lambda_exec_role_arn
  handler       = "approval_handler.approval_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.approval.output_path
  source_code_hash = data.archive_file.approval.output_base64sha256

  environment {
    variables = {
      POLICY_TEMPLATES_TABLE = "PolicyTemplatesTable"
      ACCESS_REQUESTS_TABLE  = "AccessRequestsTable"
    }
  }
}