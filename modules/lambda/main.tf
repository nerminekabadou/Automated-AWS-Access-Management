resource "aws_iam_role" "lambda_execution_role" {
  name = "iam_cleanup_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::802617578034:root"
        }
      }
    ]
  })

  tags = {
    internship = "true"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_cleanup_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DynamoDBAccess",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:dynamodb:${var.region}:*:table/${var.iam_users_table}",
          "arn:aws:dynamodb:${var.region}:*:table/${var.access_requests_table}"
        ]
      },
      {
        Sid    = "LambdaInvoke",
        Action = ["lambda:InvokeFunction"],
        Effect = "Allow",
        Resource = [
          "arn:aws:lambda:${var.region}:*:function/${var.cleanup_lambda_name}",
          "arn:aws:lambda:${var.region}:*:function/${var.cleanup_schedule_lambda_name}",
          "arn:aws:lambda:${var.region}:*:function/${var.admin_action_lambda_name}"
        ]
      },
      {
        Sid    = "SESAccess",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          StringEquals = {
            "ses:FromAddress" = var.from_email
          }
        }
      },
      {
        Sid    = "IAMCleanupActions",
        Action = [
          "iam:ListUsers",
          "iam:GetUser",
          "iam:UpdateUser",
          "iam:DeleteUser",
          "iam:ListAccessKeys",
          "iam:DeleteAccessKey",
          "iam:DeactivateMFADevice",
          "iam:DeleteLoginProfile"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid    = "BasicLambdaLogging",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "cleanup_lambda" {
  filename         = "${path.module}/../../lambda_code/cleanup.zip"
  function_name    = var.cleanup_lambda_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "cleanup.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 512
  source_code_hash = filebase64sha256("${path.module}/../../lambda_code/cleanup.zip")

  environment {
  variables = {
    USERS_TABLE        = var.iam_users_table
    ADMIN_EMAIL        = var.admin_email
    ADMIN_DECISION_URL = module.api_gateway.invoke_url  # Use the new output
    FROM_EMAIL         = var.from_email
    REGION             = var.region
    SES_TEMPLATE_NAME  = module.ses.template_name  # Add this line
  }
}
  tags = {
    internship = "true"
  }
}

resource "aws_lambda_function" "cleanup_scheduler_lambda" {
  filename         = "${path.module}/../../lambda_code/cleanup_schedule.zip"
  function_name    = var.cleanup_schedule_lambda_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "cleanup_schedule.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 512
  source_code_hash = filebase64sha256("${path.module}/../../lambda_code/cleanup_schedule.zip")

  environment {
    variables = {
      USERS_TABLE        = var.iam_users_table
      ADMIN_EMAIL        = var.admin_email
      ADMIN_DECISION_URL = var.admin_decision_url
      FROM_EMAIL         = var.from_email
      REGION             = var.region
    }
  }

  tags = {
    internship = "true"
  }
}

resource "aws_lambda_function" "admin_action_lambda" {
  filename         = "${path.module}/../../lambda_code/admin_action.zip"
  function_name    = var.admin_action_lambda_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "admin_action.lambda_handler"
  runtime          = "python3.12"
  timeout          = 300
  memory_size      = 512
  source_code_hash = filebase64sha256("${path.module}/../../lambda_code/admin_action.zip")

  environment {
    variables = {
      CLEANUP_FUNCTION_NAME = aws_lambda_function.cleanup_lambda.arn
      REGION                = var.region
    }
  }

  tags = {
    internship = "true"
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_scheduler_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.eventbridge_rule_arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.admin_action_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}