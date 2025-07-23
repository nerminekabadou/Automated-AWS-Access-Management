provider "aws" {
  region = "us-east-1"
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "AccessRequestsTable"
}

module "iam" {
  source    = "./modules/iam"
  role_name = "lambda_exec_role"
}

module "lambda_access_request" {
  source          = "./modules/lambda"
  lambda_name     = "AccessRequestLambda"
  lambda_zip_path = "${path.module}/lambda_code/access_request_handler.zip"
  handler         = "access_request_handler.lambda_handler"
  role_arn        = module.iam.role_arn
}

module "api_gateway_access_request" {
  source      = "./modules/api_gateway"
  api_name    = "access-request-api"
  lambda_arn  = module.lambda_access_request.lambda_arn
  lambda_name = "AccessRequestLambda"
  route_key   = "POST /request-access"
}
