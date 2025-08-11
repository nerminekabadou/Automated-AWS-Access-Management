provider "aws" {
  region = "us-east-2"
  
  default_tags {
    tags = {
      internship = "true"
    }
  }
}

module "dynamodb" {
  source               = "./modules/dynamodb"
  iam_users_table      = var.iam_users_table
  access_requests_table = var.access_requests_table
}

module "lambda" {
  source               = "./modules/lambda"
  iam_users_table      = var.iam_users_table
  access_requests_table = var.access_requests_table
  admin_email          = var.admin_email
  from_email           = var.from_email
  region               = var.region
  admin_decision_url   = module.api_gateway.invoke_url
}

module "api_gateway" {
  source                 = "./modules/api_gateway"
  admin_action_lambda_arn = module.lambda.admin_action_lambda_arn
  admin_action_lambda_name = module.lambda.admin_action_lambda_name
  region                = var.region
}

module "eventbridge" {
  source                      = "./modules/eventbridge"
  schedule_expression          = var.schedule_expression
  cleanup_scheduler_lambda_arn = module.lambda.cleanup_scheduler_lambda_arn
  cleanup_scheduler_lambda_name = module.lambda.cleanup_scheduler_lambda_name
}

module "ses" {
  source     = "./modules/ses"
  admin_email = var.admin_email
  from_email  = var.from_email
}

