resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"
}

# resource "aws_api_gateway_resource" "resource" {
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   parent_id   = aws_api_gateway_rest_api.this.root_resource_id
#   path_part   = var.path_part
# }

# resource "aws_api_gateway_method" "method" {
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = var.http_method
#   authorization = "NONE"
# }

resource "aws_apigatewayv2_integration" "integration" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"

}
resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "${var.http_method} /${var.path_part}"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:000000000000:${aws_apigatewayv2_api.this.id}/*/*"
}

# resource "aws_api_gateway_deployment" "this" {
#   depends_on  = [aws_api_gateway_integration.integration]
#   rest_api_id = aws_api_gateway_rest_api.this.id
# }

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true
}
