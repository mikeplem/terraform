terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "s3/social_backup"
    region = "us-east-1"
    encrypt = true
  }
}

# ==========

resource "aws_s3_bucket" "social_backup" {
  bucket = "plemmons-social-backup"
}

resource "aws_s3_bucket_acl" "social_backup" {
  bucket = aws_s3_bucket.social_backup.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "social_backup" {
  bucket = aws_s3_bucket.social_backup.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "social_backup" {
  bucket = aws_s3_bucket.social_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "social_backup" {
  bucket = aws_s3_bucket.social_backup.id
  policy = data.aws_iam_policy_document.social_backup.json
}

resource "aws_s3_bucket_versioning" "social_backup" {
  bucket = aws_s3_bucket.social_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# =======

data "aws_iam_policy_document" "social_backup" {
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
      aws_s3_bucket.social_backup.arn,
      "${aws_s3_bucket.social_backup.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
