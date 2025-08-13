module "lambda" {
  source          = "./modules/lambda"
  region          = var.region
  account_id      = var.account_id
  api_gateway_url = module.api_gateway.api_url
  api_gateway_id  = module.api_gateway.api_id
}

module "api_gateway" {
  source                    = "./modules/api_gateway"
  region                    = var.region
  api_name                  = var.api_name
  access_request_lambda_arn = module.lambda.access_request_function_arn
  approval_lambda_arn       = module.lambda.approval_function_arn
}

module "dynamodb" {
  source = "./modules/dynamodb"
}