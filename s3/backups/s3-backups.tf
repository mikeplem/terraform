terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "s3/backups"
    region = "us-east-1"
    encrypt = true
  }
}

# ==========

# terraform import aws_s3_bucket.backups plemmons-backups
resource "aws_s3_bucket" "backups" {
  bucket = "plemmons-backups"
}

# terraform import aws_s3_bucket_acl.backups plemmons-backups
resource "aws_s3_bucket_acl" "backups" {
  bucket = aws_s3_bucket.backups.id
  acl    = "private"
}

# terraform import aws_s3_bucket_server_side_encryption_configuration.backups plemmons-backups
resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# terraform import aws_s3_bucket_public_access_block.backups plemmons-backups
resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# terraform import aws_s3_bucket_policy.backups plemmons-backups
resource "aws_s3_bucket_policy" "backups" {
  bucket = aws_s3_bucket.backups.id
  policy = data.aws_iam_policy_document.backups.json
}

# terraform import aws_s3_bucket_lifecycle_configuration.backups plemmons-backups
resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id = "DeleteWebConfigOlderThan32Days"
    status = "Enabled"

    filter {
      prefix = "n1mtp.com/tmp/*"
    }

    expiration {
      days = 32
    }
    noncurrent_version_expiration {
      noncurrent_days = 32
    }
  }

  rule {
    id = "DeleteOwncloudOlderThan32Days"
    status = "Enabled"

    filter {
      prefix = "owncloud.n1mtp.com/tmp/*"
    }

    expiration {
      days = 32
    }

    noncurrent_version_expiration {
      noncurrent_days = 32
    }
  }
}

# =======

data "aws_iam_policy_document" "backups" {
  policy_id = "PutObjPolicy"

  statement {
    sid = "DenyIncorrectEncryptionHeader"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.backups.arn}/*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }

  statement {
    sid = "DenyUnEncryptedObjectUploads"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.backups.arn}/*",
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

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
      aws_s3_bucket.backups.arn,
      "${aws_s3_bucket.backups.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

  }
}