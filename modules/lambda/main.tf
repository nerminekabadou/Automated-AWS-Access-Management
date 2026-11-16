# All three functions are packaged from lambda_code/ so they can share
# decision_token.py. The zip is rebuilt whenever the code changes.
data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.root}/lambda_code"
  output_path = "${path.root}/build/lambda_code.zip"
  excludes    = ["__pycache__", "tests"]
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "iam_cleanup_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_cleanup_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "DynamoDBAccess",
        Effect   = "Allow",
        Action   = ["dynamodb:Scan", "dynamodb:UpdateItem"],
        Resource = "arn:aws:dynamodb:${var.region}:${local.account_id}:table/${var.iam_users_table}"
      },
      {
        Sid      = "InvokeCleanup",
        Effect   = "Allow",
        Action   = ["lambda:InvokeFunction"],
        Resource = "arn:aws:lambda:${var.region}:${local.account_id}:function:${var.cleanup_lambda_name}"
      },
      {
        Sid      = "SESAccess",
        Effect   = "Allow",
        Action   = ["ses:SendEmail", "ses:SendTemplatedEmail"],
        Resource = "*",
        Condition = {
          StringEquals = { "ses:FromAddress" = var.from_email }
        }
      },
      {
        Sid    = "IAMCleanupActions",
        Effect = "Allow",
        Action = [
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey",
          "iam:DeleteAccessKey",
          "iam:DeleteLoginProfile",
          "iam:ListMFADevices",
          "iam:DeactivateMFADevice",
          "iam:ListAttachedUserPolicies",
          "iam:DetachUserPolicy",
          "iam:ListUserPolicies",
          "iam:DeleteUserPolicy",
          "iam:ListGroupsForUser",
          "iam:RemoveUserFromGroup",
          "iam:DeleteUser"
        ],
        Resource = "arn:aws:iam::${local.account_id}:user/*"
      },
      {
        Sid      = "BasicLambdaLogging",
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "cleanup_lambda" {
  function_name    = var.cleanup_lambda_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "cleanup.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      USERS_TABLE = var.iam_users_table
    }
  }
}

resource "aws_lambda_function" "cleanup_scheduler_lambda" {
  function_name    = var.cleanup_schedule_lambda_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "cleanup_schedule.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      USERS_TABLE        = var.iam_users_table
      ADMIN_EMAIL        = var.admin_email
      FROM_EMAIL         = var.from_email
      ADMIN_DECISION_URL = var.admin_decision_url
      SES_TEMPLATE_NAME  = var.ses_template_name
      DECISION_SECRET    = var.decision_secret
      LINK_TTL_HOURS     = tostring(var.link_ttl_hours)
    }
  }
}

resource "aws_lambda_function" "admin_action_lambda" {
  function_name    = var.admin_action_lambda_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "admin_action.lambda_handler"
  runtime          = "python3.12"
  timeout          = 30
  filename         = data.archive_file.lambda_code.output_path
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      CLEANUP_FUNCTION_NAME = aws_lambda_function.cleanup_lambda.arn
      DECISION_SECRET       = var.decision_secret
    }
  }
}
