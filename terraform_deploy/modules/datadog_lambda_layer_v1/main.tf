resource "aws_lambda_layer_version" "lambda_layer" {
  s3_bucket           = var.lambda_bucket
  s3_key              = var.lambda_package_key
  layer_name          = "${var.resource_prefix}datadog-lambda-layer-python"
  compatible_runtimes = var.compatible_runtimes
}
