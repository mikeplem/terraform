terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "s3/restic"
    region = "us-east-1"
    encrypt = true
  }
}

# ==========

# terraform import aws_s3_bucket.restic plemmons-restic
resource "aws_s3_bucket" "restic" {
  bucket = "plemmons-restic"
}

# terraform import aws_s3_bucket_acl.restic plemmons-restic
resource "aws_s3_bucket_acl" "restic" {
  bucket = aws_s3_bucket.restic.id
  acl    = "private"
}

# terraform import aws_s3_bucket_server_side_encryption_configuration.restic plemmons-restic
resource "aws_s3_bucket_server_side_encryption_configuration" "restic" {
  bucket = aws_s3_bucket.restic.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# terraform import aws_s3_bucket_public_access_block.restic plemmons-restic
resource "aws_s3_bucket_public_access_block" "restic" {
  bucket = aws_s3_bucket.restic.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# terraform import aws_s3_bucket_policy.restic plemmons-restic
resource "aws_s3_bucket_policy" "restic" {
  bucket = aws_s3_bucket.restic.id
  policy = data.aws_iam_policy_document.restic.json
}

# =======

data "aws_iam_policy_document" "restic" {
  policy_id = "PutObjPolicy"

  statement {
    sid = "EnforceEncryptedTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.restic.arn,
      "${aws_s3_bucket.restic.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

  }
}