variable "resource_prefix" {
  type = string
}

variable "compatible_runtimes" {
  type        = list(string)
  description = "Compatible runtimes like python2.7 , python3.7"
}

variable "lambda_bucket" {
  description = "S3 bucket where the Lambda deployment packages are to be fetched from."
}

variable "lambda_package_key" {
  description = "S3 bucket key specifying the specific Lambda deployment packages to be deployed."
}
