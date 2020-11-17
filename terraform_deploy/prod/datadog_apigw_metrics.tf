module "datadog_lambda_python_layer" {
  source              = "../modules/datadog_lambda_layer_v1"
  resource_prefix     = local.dd_resource_prefix
  lambda_bucket       = local.lambda_packages_bucket
  lambda_package_key  = var.datadog_lambda_layer_package_key
  compatible_runtimes = ["python3.7"]
}

module "datadog_apigw_metrics_v1" {
  source             = "../modules/datadog_apigw_metrics_v1"
  aws_region         = local.dd_aws_region
  resource_prefix    = local.dd_resource_prefix
  environment        = var.environment
  product            = var.product
  lambda_bucket      = local.lambda_packages_bucket
  lambda_package_key = var.datadog_apigw_metrics_lambda_package_key
  lambda_layer_arn   = [module.datadog_lambda_python_layer.aws_lambda_layer_version_arn]
  dd_api_key         = var.dd_api_key
  dd_app_key         = var.dd_app_key
}

locals {
  dd_aws_region          = terraform.workspace == "default" ? "us-west-1" : terraform.workspace
  lambda_packages_bucket = lookup(var.lambda_packages_bucket, local.dd_aws_region)
  dd_resource_prefix     = lookup(var.resource_prefix, local.dd_aws_region)
}
