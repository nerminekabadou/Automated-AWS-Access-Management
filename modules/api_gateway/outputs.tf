output "api_id" {
  value = aws_api_gateway_rest_api.this.id
}

data "aws_region" "current" {}

output "api_url" {
  description = "The base URL for the deployed API Gateway stage"
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}