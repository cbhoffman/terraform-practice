resource "aws_s3_bucket" "tf-state" {
  bucket = "cbh-tf-state-practice"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "TF practice bucket"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_encryption" {
  bucket = aws_s3_bucket.tf-state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tf-state.id
  versioning_configuration {
    status = "Enabled"
  }
}