variable "resource_prefix" {}

variable "aws_region" {}

variable "environment" {}

variable "product" {}

variable "lambda_bucket" {
  description = "S3 bucket where the Lambda deployment packages are to be fetched from."
}

variable "lambda_package_key" {
  description = "S3 bucket key specifying the specific Lambda deployment packages to be deployed."
}

variable "lambda_layer_arn" {
  type        = list(string)
  description = "Datadog python lambda layer which is attached to main lambda function"
}

variable "dd_app_key" {
  type        = string
  description = "Datadog app key used by lambda to call DD API's"
}

variable "dd_api_key" {
  type        = string
  description = "Datadog api key used by lambda to call DD API's"
}
