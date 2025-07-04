resource "aws_sns_topic" "alerts" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "emails" {
  count     = length(var.email_subscriptions)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_subscriptions[count.index]
}
