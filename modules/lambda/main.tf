#Used directly the Role provided by the supervisor
variable "lambda_exec_role_arn" {
  type        = string
  description = "ARN of the existing Lambda execution role"
  default     = "arn:aws:iam::802617578034:role/role-for-interns"
}

resource "aws_lambda_function" "access_request" {
  function_name = "access-request"
  role          = var.lambda_exec_role_arn
  handler       = "access_request_handler.access_request_handler"
  runtime       = "python3.11"

  filename         = "${path.root}/lambda_code/access_request.zip"
  source_code_hash = filebase64sha256("${path.root}/lambda_code/access_request.zip")

  environment {
    variables = {
      POLICY_TEMPLATES_TABLE = "PolicyTemplatesTable"
      ACCESS_REQUESTS_TABLE  = "AccessRequestsTable"
    }
  }
}

resource "aws_lambda_function" "approval" {
  function_name = "approval"
  role          = var.lambda_exec_role_arn
  handler       = "approval_handler.approval_handler"
  runtime       = "python3.11"

  filename         = "${path.root}/lambda_code/approval.zip"
  source_code_hash = filebase64sha256("${path.root}/lambda_code/approval.zip")

  environment {
    variables = {
      POLICY_TEMPLATES_TABLE = "PolicyTemplatesTable"
      ACCESS_REQUESTS_TABLE  = "AccessRequestsTable"
    }
  }
}