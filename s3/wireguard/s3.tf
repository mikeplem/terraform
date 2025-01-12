terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "s3/wireguard"
    region = "us-east-1"
    encrypt = true
  }
}

# ==========

resource "aws_s3_bucket" "wireguard" {
  bucket = "plemmons-wireguard"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "wireguard" {
  bucket = aws_s3_bucket.wireguard.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "wireguard" {
  bucket = aws_s3_bucket.wireguard.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
