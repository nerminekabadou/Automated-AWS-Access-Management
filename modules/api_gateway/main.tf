resource "aws_apigatewayv2_api" "admin_api" {
  name          = "AdminActionAPI"
  protocol_type = "HTTP"
  
  tags = {
    internship = "true"
  }
}

resource "aws_apigatewayv2_integration" "admin_integration" {
  api_id           = aws_apigatewayv2_api.admin_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.admin_action_lambda_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "admin_route" {
  api_id    = aws_apigatewayv2_api.admin_api.id
  route_key = "POST /decision"
  target    = "integrations/${aws_apigatewayv2_integration.admin_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.admin_api.id
  name        = "$default"
  auto_deploy = true
  
  tags = {
    internship = "true"
  }
}

resource "aws_lambda_permission" "allow_apigw_to_invoke_admin" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.admin_action_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.admin_api.execution_arn}/*/*"
}