## Bucket for TF state storage
resource "aws_s3_bucket" "tfstate" {
  bucket = "serokell-aquarius-tfstate"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

## DynamoDB for TF locking and state
resource "aws_dynamodb_table" "tfstatelock" {
  name = "serokell-aquarius-tfstate-lock"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  lifecycle {
    prevent_destroy = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
