resource "aws_s3_bucket" "rmstate_folder" {
  bucket = var.rmstate_s3_bucket
  count  = var.aws_region == "eu-central-1" ? 1 : 0

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  # Enable versioning by default
  versioning {
    enabled = true
  }
  # bucket level as this repo is using already exisitng bucket 
  tags = merge({
    "Name" = format("${var.resource_prefix}%s", "rmstate-s3-bucket-object")
  }, var.default_tags)
}
