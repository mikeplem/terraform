terraform {
  backend "s3" {
    bucket = "plemmons-terraform-base"
    key    = "s3/network/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

resource "aws_s3_bucket" "terraform" {
  bucket = "plemmons-terraform-network"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform" {
  bucket = aws_s3_bucket.terraform.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# resource "aws_s3_bucket_policy" "terraform" {
#   bucket = aws_s3_bucket.terraform.id
#   policy = data.aws_iam_policy_document.terraform.json
# }

# # =======

# data "aws_iam_policy_document" "terraform" {
#   policy_id = "PutObjPolicy"

#   statement {
#     sid = "EnforceEncryptedTransport"
#     effect = "Deny"

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:*",
#     ]

#     resources = [
#       aws_s3_bucket.terraform.arn,
#       "${aws_s3_bucket.terraform.arn}/*",
#     ]

#     condition {
#       test     = "Bool"
#       variable = "aws:SecureTransport"
#       values   = ["false"]
#     }

#   }
# }
