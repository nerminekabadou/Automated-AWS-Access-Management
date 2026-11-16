provider "aws" {
  region = var.region

  default_tags {
    tags = {
      internship = "true"
    }
  }
}

# Shared secret used to sign the decision links sent to the admin.
resource "random_password" "decision_secret" {
  length  = 48
  special = false
}

module "dynamodb" {
  source          = "./modules/dynamodb"
  iam_users_table = var.iam_users_table
}

module "ses" {
  source      = "./modules/ses"
  admin_email = var.admin_email
  from_email  = var.from_email
}

module "lambda" {
  source                       = "./modules/lambda"
  region                       = var.region
  iam_users_table              = var.iam_users_table
  cleanup_lambda_name          = var.cleanup_lambda_name
  cleanup_schedule_lambda_name = var.cleanup_schedule_lambda_name
  admin_action_lambda_name     = var.admin_action_lambda_name
  admin_email                  = var.admin_email
  from_email                   = var.from_email
  admin_decision_url           = module.api_gateway.invoke_url
  ses_template_name            = module.ses.template_name
  decision_secret              = random_password.decision_secret.result
  link_ttl_hours               = var.link_ttl_hours
}

module "api_gateway" {
  source                   = "./modules/api_gateway"
  admin_action_lambda_arn  = module.lambda.admin_action_lambda_arn
  admin_action_lambda_name = module.lambda.admin_action_lambda_name
}

module "eventbridge" {
  source                        = "./modules/eventbridge"
  schedule_expression           = var.schedule_expression
  cleanup_scheduler_lambda_arn  = module.lambda.cleanup_scheduler_lambda_arn
  cleanup_scheduler_lambda_name = module.lambda.cleanup_scheduler_lambda_name
}
