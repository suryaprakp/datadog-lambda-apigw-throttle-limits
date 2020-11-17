variable "rmstate_s3_bucket" {
  description = "S3 bucket name where terraform state file is stored"
  type        = string
}

variable "resource_prefix" {
  description = "Resource prefix added to all the resouces provisioned through this module"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "Resource prefix added to all the resouces provisioned through this module"
  type        = string
  default     = "default"
}

variable "default_tags" {
  description = "Default tags added to all the resouces"
  type        = map(string)
}
