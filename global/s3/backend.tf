provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-backend-state"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "S3 backend"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-backend-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "Dynamo-Backend"
  }
}
