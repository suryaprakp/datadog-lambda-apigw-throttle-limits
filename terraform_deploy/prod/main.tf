terraform {
  required_version = ">= 0.12, < 0.13"

  required_providers {
    aws = "~> 2.0"
  }

  backend "s3" {
    bucket               = "prod-apigwlimits-terraform-state"
    key                  = "terraform.tfstate"
    region               = "eu-central-1"
    dynamodb_table       = "terraform-ssm-state"
    encrypt              = true
    workspace_key_prefix = "aws-apigwlimits-metrics"
    //role_arn             = "arn:aws:iam::021785113572:role/RoleName"
  }
}

provider "aws" {

  region              = local.aws_region
  allowed_account_ids = [var.aws_allowed_account_id]

  # Allow any 2.56.0 version of the AWS provider
  version = "~> 2.56.0"

  # Assume role for prod , This should only be used when done locally as TC credentials doesnt have permissions to do so
  /*assume_role {
    role_arn     = "arn:aws:iam::021785113572:role/RoleName"
    session_name = "terraform-dd-metrics-01"
  }*/
}

locals {
  aws_region = terraform.workspace == "default" ? "us-west-1" : terraform.workspace
}
