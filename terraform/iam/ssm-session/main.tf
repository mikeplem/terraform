data "aws_iam_policy_document" "ssm_access" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:Get*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "ssm:StartSession",
    ]

    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ssm:us-east-1::document/AWS-StartInteractiveCommand"
    ]

    condition {
      test     = "StringLike"
      variable = "ssm:resourceTag/Name"

      values = [
        "rds_bastion",
      ]
    }
  }

  statement {
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession",
    ]

    resources = [
      "arn:aws:ssm:*:*:session/&{aws:username}-*"
    ]
  }
}

resource "aws_iam_user" "ssm_access" {
  name = "ssm_access"
  path = "/"
}

resource "aws_iam_access_key" "ssm_access" {
  user = aws_iam_user.ssm_access.name
}

resource "aws_iam_user_policy" "ssm_access" {
  name = "ssm_access-s3"
  user = aws_iam_user.ssm_access.name
  policy = data.aws_iam_policy_document.ssm_access.json
}

resource "aws_ssm_parameter" "ssm_access" {
  name  = "/iam/ssm-session"
  type  = "SecureString"
  value = jsonencode({"username"=aws_iam_access_key.ssm_access.id,"password"=aws_iam_access_key.ssm_access.secret})

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
