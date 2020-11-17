
variable "environment" {
  description = "Deploy environment (e.g. 'lab' or 'prod')"
  type        = string
}

variable "product" {
  description = "Product (e.g. 'calling' or 'verification' or 'Infra')"
  type        = string
}

variable "service" {
  description = "Service name used for tagging"
  type        = string
}

variable "default_tags" {
  description = "Default tags added to all the resouces"
  type        = map(string)
}

variable "resource_prefix" {
  # The character limit for most AWS resource names are 64 chars, but
  # we want to be able to use this resource prefix also with ELBs,
  # which derives their DNS name from the resource name, and that
  # require a limit of 32 characters.
  #
  # Note that some of our AWS policies applies to resources with a
  # particular resource name prefix (e.g. ft*).
  #
  # Further, when the resource prefix is used for naming e.g. IAM
  # resources like policies and roles, we want the resource_prefix to
  # make the resource unique to conform to the name restrictions of
  # IAM resources (see
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-limits.html)
  description = "Prefix that will be added to all AWS resource names. Consider that the prefix plus resource name must not exceed 32 characters."
  type        = map(string)
  default = {
    "eu-central-1" = "euc1-dd-metrics-infra-",
    "eu-west-1"    = "euw1-dd-metrics-infra-",
    "us-west-1"    = "usw1-dd-metrics-infra-",
    "us-west-2"    = "usw2-dd-metrics-infra-",
    "us-east-2"    = "use2-dd-metrics-infra-",
    "eu-north-1"   = "eun1-dd-metrics-infra-",
  }
}

