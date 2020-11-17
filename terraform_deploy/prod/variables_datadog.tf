# THIS FILE IS GENERATED from a .tf.link file. DO NOT EDIT.
variable "dd_app_key" {
  type        = string
  description = "Datadog app key used by lambda to call DD API's"
}

variable "dd_api_key" {
  type        = string
  description = "Datadog api key used by lambda to call DD API's"
}

variable "datadog_lambda_layer_package_key" {
  description = "S3 bucket in which AWS Lambda layer deployment package resides for Datadog library"
}

variable "datadog_apigw_metrics_lambda_package_key" {
  description = "S3 bucket in which AWS Lambda deployment package resides for Datadog apigw metrics"
}

variable "lambda_packages_bucket" {

  description = "lambda packages bucket for different regions"
  type        = map(string)
  default = {
    "eu-central-1" = "aws-lambda-packages-euc1",
    "eu-north-1"   = "aws-lambda-packages-eun1",
    "eu-west-1"    = "aws-lambda-packages-euw1",
    "us-west-1"    = "aws-lambda-packages-usw1",
    "us-west-2"    = "aws-lambda-packages-usw2",
    "us-east-2"    = "aws-lambda-packages-use2"
  }
}
