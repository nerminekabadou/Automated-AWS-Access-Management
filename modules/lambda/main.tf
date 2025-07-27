resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

# Add any additional policies your Lambda functions need
resource "aws_lambda_function" "access_request" {
  function_name = "access-request"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "access_request_handler.access_request_handler"
  runtime       = "python3.11"

  filename         = "${path.root}/lambda_code/access_request.zip"
  source_code_hash = filebase64sha256("${path.root}/lambda_code/access_request.zip")
}
resource "aws_lambda_function" "approval" {
  function_name = "approval"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "approval_handler.approval_handler"
  runtime       = "python3.11"

  filename         = "${path.root}/lambda_code/approval.zip"
  source_code_hash = filebase64sha256("${path.root}/lambda_code/approval.zip")
}