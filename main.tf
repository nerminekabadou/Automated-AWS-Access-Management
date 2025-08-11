module "lambda" {
  source          = "./modules/lambda"
  region          = var.region
  account_id      = var.account_id
  api_gateway_url = module.api_gateway.api_url
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

terraform {
  backend "s3" {
    bucket         = "our-terraform-state-bucket"
    key            = "internshipproject/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}