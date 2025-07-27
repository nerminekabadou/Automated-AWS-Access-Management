resource "aws_lambda_function" "template_submission_lambda" {
  function_name = "TemplateSubmissionLambda"
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.template_submission_lambda_key
  handler       = "TemplateSubmissionLambda.handler"
  runtime       = "python3.9"
  role          = var.lambda_role_arn

  environment {
    variables = {
      ACCESS_REQUEST_TABLE = var.dynamodb_access_request_table
      STATE_MACHINE_ARN    = aws_sfn_state_machine.provisioning_workflow.arn
    }
  }
}

resource "aws_lambda_function" "provisioning_lambda" {
  function_name = "ProvisioningLambda"
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = var.provisioning_lambda_key
  handler       = "ProvisioningLambda.handler"
  runtime       = "python3.9"
  role          = var.lambda_role_arn

  environment {
    variables = {
      IAM_USERS_TABLE      = var.dynamodb_iam_users_table
      ACCESS_REQUEST_TABLE = var.dynamodb_access_request_table
    }
  }
}

resource "aws_sfn_state_machine" "provisioning_workflow" {
  name     = "ProvisioningWorkflow"
  role_arn = var.lambda_role_arn

  definition = jsonencode({
    Comment = "Provision IAM user",
    StartAt = "Provision",
    States = {
      Provision = {
        Type     = "Task",
        Resource = aws_lambda_function.provisioning_lambda.arn,
        End      = true
      }
    }
  })
}

resource "aws_api_gateway_rest_api" "admin_api" {
  name = "AdminTemplateAPI"
}

resource "aws_api_gateway_resource" "submit_template" {
  rest_api_id = aws_api_gateway_rest_api.admin_api.id
  parent_id   = aws_api_gateway_rest_api.admin_api.root_resource_id
  path_part   = "submit-template"
}

resource "aws_api_gateway_method" "post_submit" {
  rest_api_id   = aws_api_gateway_rest_api.admin_api.id
  resource_id   = aws_api_gateway_resource.submit_template.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_submit" {
  rest_api_id             = aws_api_gateway_rest_api.admin_api.id
  resource_id             = aws_api_gateway_resource.submit_template.id
  http_method             = aws_api_gateway_method.post_submit.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.template_submission_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.template_submission_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.admin_api.execution_arn}/*/*"
}