output "rest_api_id" {
  value = aws_apigatewayv2_api.this.id
}

output "execution_arn" {
  value = aws_apigatewayv2_api.this.execution_arn
}

output "stage_arn" {
  value = aws_apigatewayv2_stage.stage.arn
}
