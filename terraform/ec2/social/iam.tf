data "aws_iam_policy_document" "social_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "social" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*",
    ]

    resources = [
      "arn:aws:s3:::plemmons-social",
      "arn:aws:s3:::plemmons-social/*",
    ]
  }

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
      "ssm:Describe*",
      "ssm:Get*",
    ]

    resources = [
      aws_ssm_parameter.social.arn
    ]
  }
}

data "aws_iam_policy_document" "social_s3" {
  statement {
    actions = [
      "s3:List*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*",
    ]

    resources = [
      "arn:aws:s3:::plemmons-social",
      "arn:aws:s3:::plemmons-social/*",
    ]
  }
}

resource "aws_iam_role_policy" "social" {
  name   = "social"
  role   = aws_iam_role.social.id
  policy = data.aws_iam_policy_document.social.json
}

resource "aws_iam_role" "social" {
  name               = "social_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.social_assume.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "social" {
  name = "social"
  role = aws_iam_role.social.name
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "social" {
  role       = aws_iam_role.social.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_user" "social" {
  name = "social-s3"
  path = "/"
  tags = var.tags
}

resource "aws_iam_access_key" "social" {
  user = aws_iam_user.social.name
}

resource "aws_iam_user_policy" "social" {
  name = "social-s3"
  user = aws_iam_user.social.name
  policy = data.aws_iam_policy_document.social_s3.json
}