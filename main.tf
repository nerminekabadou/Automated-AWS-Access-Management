module "lambda" {
  source = "./modules/lambda"
}
module "api_gateway" {
  source                    = "./modules/api_gateway"
  region                    = var.region
  api_name                  = var.api_name
  access_request_lambda_arn = module.lambda.access_request_function_arn
  approval_lambda_arn       = module.lambda.approval_function_arn
}