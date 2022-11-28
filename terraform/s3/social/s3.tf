terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "s3/social"
    region = "us-east-1"
    encrypt = true
  }
}

# ==========

resource "aws_s3_bucket" "social" {
  bucket = "plemmons-social"
}

resource "aws_s3_bucket_acl" "social" {
  bucket = aws_s3_bucket.social.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "social" {
  bucket = aws_s3_bucket.social.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "social" {
  bucket = aws_s3_bucket.social.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "social" {
  bucket = aws_s3_bucket.social.id
  policy = data.aws_iam_policy_document.social.json
}

# =======

data "aws_iam_policy_document" "social" {
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
      aws_s3_bucket.social.arn,
      "${aws_s3_bucket.social.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.social.arn}/*",
    ]
  }
}