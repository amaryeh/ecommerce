output "lambda_log_group_name" {
  value = aws_cloudwatch_log_group.lambda.name
}

output "lambda_error_alarm_name" {
  value = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
}
