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
  depends_on       = [aws_iam_role_policy_attachment.lambda_basic]
  function_name = "access-request"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "access_request_handler.access_request_handler"
  runtime       = "python3.11"

  filename         = "${path.root}/lambda_code/access_request.zip"
  source_code_hash = filebase64sha256("${path.root}/lambda_code/access_request.zip")
    environment {
    variables = {
      POLICY_TEMPLATES_TABLE = "PolicyTemplatesTable"
      ACCESS_REQUESTS_TABLE = "AccessRequestsTable"
    }
  }
}
resource "aws_lambda_function" "approval" {
  function_name = "approval"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "approval_handler.approval_handler"
  runtime       = "python3.11"

  filename         = "${path.root}/lambda_code/approval.zip"
  source_code_hash = filebase64sha256("${path.root}/lambda_code/approval.zip")
   environment {
    variables = {
      POLICY_TEMPLATES_TABLE = "PolicyTemplatesTable"
      ACCESS_REQUESTS_TABLE = "AccessRequestsTable"
    }
  }
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "lambda_dynamodb_policy"
  description = "Policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [
          "arn:aws:dynamodb:${var.region}:${var.account_id}:table/AccessRequestsTable",
          "arn:aws:dynamodb:${var.region}:${var.account_id}:table/AccessRequestsTable/index/*",
          "arn:aws:dynamodb:${var.region}:${var.account_id}:table/PolicyTemplatesTable"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_policy" "lambda_ses" {
  name        = "lambda_ses_policy"
  description = "Policy for Lambda to send emails via SES"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses" {
  policy_arn = aws_iam_policy.lambda_ses.arn
  role       = aws_iam_role.lambda_exec.name
}