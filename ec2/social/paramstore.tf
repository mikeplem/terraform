resource "random_password" "password" {
  length           = 24
  special          = false
}

resource "aws_ssm_parameter" "social" {
  name  = "/mastadon/db_pass"
  type  = "SecureString"
  value = random_password.password.result
  tags  = var.tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "social_gmail" {
  name  = "/mastadon/gmail"
  type  = "SecureString"
  value = "placeholder"
  tags  = var.tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "social_s3" {
  name  = "/mastadon/s3"
  type  = "SecureString"
  value = jsonencode({"username"=aws_iam_access_key.social.id,"password"=aws_iam_access_key.social.secret})
  tags  = var.tags

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
