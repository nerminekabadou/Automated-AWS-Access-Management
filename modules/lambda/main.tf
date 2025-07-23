resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  filename      = var.lambda_zip_path
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  timeout       = 10
}
