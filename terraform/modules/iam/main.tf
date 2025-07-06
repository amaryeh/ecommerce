resource "aws_iam_role" "lambda_exec" {
  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.role_name}-policy"
  description = "Least-privilege policy for Lambda execution"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.policy_statements
  })
}
resource "aws_iam_role_policy_attachment" "custom_inline" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "managed_policies" {
  count      = length(var.attach_managed_policies)
  role       = aws_iam_role.lambda_exec.name
  policy_arn = var.attach_managed_policies[count.index]
}
resource "aws_iam_policy" "secrets_access" {
  name = "ProductAPISecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = "arn:aws:secretsmanager:REGION:ACCOUNT_ID:secret:product-api-key*"
      }
    ]
  })
}

