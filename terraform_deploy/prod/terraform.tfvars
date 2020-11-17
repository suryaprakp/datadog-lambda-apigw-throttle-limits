environment = "prod"
product     = "infra"
service     = "ssm"

aws_allowed_account_id = "021785113572"

default_tags = {
  Environment = "prod"
  Service     = "ssm"
  Product     = "infra"
  Terraform   = true
}

datadog_apigw_metrics_lambda_package_key = "datadog-lambda-apigw-metrics/datadog_apigw_metrics_lambdafunction-dcad353-17.zip"
datadog_lambda_layer_package_key = "datadog-lambda-layer-python/datadog_lambda_layer_py3.7-dcad353-14.zip"