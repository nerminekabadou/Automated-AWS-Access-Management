# Create the REST API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name = var.api_name
}

# Create the /request-access resource under the root path
resource "aws_api_gateway_resource" "request_access" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "request-access"
}

# Create the POST method for the /request-access resource
resource "aws_api_gateway_method" "request_access_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.request_access.id
  http_method   = "POST"
  authorization = "NONE"  # No authentication required
}

# Integrate the POST /request-access method with a Lambda function using AWS_PROXY
resource "aws_api_gateway_integration" "request_access_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.request_access.id
  http_method             = aws_api_gateway_method.request_access_post.http_method
  integration_http_method = "POST"  # Required by Lambda integration
  type                    = "AWS_PROXY"  # Proxy integration (passes request directly to Lambda)
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${var.access_request_lambda_arn}/invocations"  # Lambda ARN to invoke
}

# Create the /approve resource under the root path
resource "aws_api_gateway_resource" "approve" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "approve"
}

# Create a dynamic subresource /approve/{request_id}
resource "aws_api_gateway_resource" "approve_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.approve.id
  path_part   = "{request_id}"  # Path parameter for request ID
}

# Create the GET method for /approve/{request_id}
resource "aws_api_gateway_method" "approve_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.approve_id.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.request_id" = true
  }
}

# Integrate GET /approve/{request_id} with the approval Lambda
resource "aws_api_gateway_integration" "approve_integration" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.approve_id.id
  http_method             = aws_api_gateway_method.approve_get.http_method
  integration_http_method = "POST" # still POST to Lambda
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:eu-west-2:lambda:path/2015-03-31/functions/${var.approval_lambda_arn}/invocations"
}

# Deploy the API (must be done to make it available on the internet)
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.request_access_integration,
    aws_api_gateway_integration.approve_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true  // Ensure new deployment is created before destroying the old one, i did it when i changed from method POST to GET of the lambda function: approval
  }
}

# Create a stage named "prod" where the API will be deployed
resource "aws_api_gateway_stage" "prod" {
  rest_api_id    = aws_api_gateway_rest_api.this.id
  deployment_id  = aws_api_gateway_deployment.this.id
  stage_name     = "prod"
}

# Allow API Gateway to invoke the AccessRequest Lambda
resource "aws_lambda_permission" "allow_api_gateway_access_request" {
  statement_id  = "AllowExecutionFromAPIGatewayRequestAccess"
  action        = "lambda:InvokeFunction"
  function_name = var.access_request_lambda_arn
  principal     = "apigateway.amazonaws.com"
  
  # Add source ARN for better security
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# Allow API Gateway to invoke the Approval Lambda
resource "aws_lambda_permission" "allow_api_gateway_approval" {
  statement_id  = "AllowExecutionFromAPIGatewayApproval"
  action        = "lambda:InvokeFunction"
  function_name = var.approval_lambda_arn
  principal     = "apigateway.amazonaws.com"
  
  # Add source ARN for better security
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}