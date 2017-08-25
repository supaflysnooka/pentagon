resource "aws_s3_bucket" "terraform_state_store" {
  bucket = "${var.infrastructure_name}-terraform"
  acl    = "private"

  versioning {
    enabled = true
  }
}

variable "infrastructure_name" {}
