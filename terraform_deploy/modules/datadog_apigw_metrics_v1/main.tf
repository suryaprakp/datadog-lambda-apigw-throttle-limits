data "aws_iam_policy_document" "datadog_apigw_metrics" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_apigw_metrics_policy" {
  name   = "${var.resource_prefix}datadog-apigw-metrics-policy"
  policy = data.aws_iam_policy_document.datadog_apigw_metrics.json
}

resource "aws_iam_role" "datadog_apigw_metrics" {
  name = "${var.resource_prefix}datadog-apigw-metrics"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "autoupdate_lambda" {
  name       = "${var.resource_prefix}datadog-apigw-metrics"
  roles      = ["${aws_iam_role.datadog_apigw_metrics.name}"]
  policy_arn = aws_iam_policy.datadog_apigw_metrics_policy.arn
}

resource "aws_kms_key" "datadog_keys" {
  description         = "Master key to encrypt and decrypt datadog keys"
  enable_key_rotation = true
  is_enabled          = true

  tags = {
    Name        = "${var.resource_prefix}kms-key-datadog"
    Environment = var.environment
    Product     = var.product
  }
}

data "aws_kms_ciphertext" "datadogkeys-cipher" {
  key_id = aws_kms_key.datadog_keys.id

  plaintext = <<EOF
{
  "api_key": "${var.dd_api_key}",
  "app_key": "${var.dd_app_key}"
}
EOF
}

resource "aws_kms_grant" "datadog_keys_grant" {

  name              = "${var.resource_prefix}datadog-apigw-metrics-grant"
  key_id            = aws_kms_key.datadog_keys.id
  grantee_principal = aws_iam_role.datadog_apigw_metrics.arn
  operations        = ["Encrypt", "Decrypt"]
}

resource "aws_lambda_function" "datadog_apigw_metrics" {
  description = "Function is invoked every 1 minute. The function fetches all API gateways throttle limits within region and post it to DD server as custom metric"

  s3_bucket = var.lambda_bucket
  s3_key    = var.lambda_package_key

  function_name = "${var.resource_prefix}datadog-apigw-metrics"
  layers        = var.lambda_layer_arn

  role        = aws_iam_role.datadog_apigw_metrics.arn
  handler     = "datadog_apigw_metrics.lambda_handler"
  runtime     = "python3.7"
  timeout     = 80
  kms_key_arn = aws_kms_key.datadog_keys.arn

  environment {
    variables = {
      DATADOG_API_KEY = data.aws_kms_ciphertext.datadogkeys-cipher.ciphertext_blob
    }
  }

  tags = {
    Environment = var.environment
    Product     = var.product
    Name        = "${var.resource_prefix}datadog-apigw-metrics"
  }
}

# create cloudwatch event rule
resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "${var.resource_prefix}datadog_apigw_metrics_event"
  description         = "Trigger Lambda function every 1 minute for plotting DD time series metrics"
  schedule_expression = "rate(1 minute)"
}

# invoke lambda when the cloudwatch event rule triggers
resource "aws_cloudwatch_event_target" "invoke-lambda" {
  rule      = aws_cloudwatch_event_rule.every_one_minute.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.datadog_apigw_metrics.arn
}

# permit cloudwatch event rule to invoke lambda
resource "aws_lambda_permission" "lambda_permissions" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.datadog_apigw_metrics.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_minute.arn
}
