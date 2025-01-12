data "aws_iam_policy_document" "windows" {
  statement {
    actions = [
      "ssm:PutParameter",
    ]

    resources = [
      "arn:aws:ssm:*:*:parameter/EC2Rescue/Passwords/i-*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:Get*",
      "s3:Put*",
    ]

    resources = [
      "arn:aws:s3:::plemmons-backups",
      "arn:aws:s3:::plemmons-backups/*",
    ]
  }
}

resource "aws_iam_role_policy" "windows" {
  name   = "windows"
  role   = aws_iam_role.windows.id
  policy = data.aws_iam_policy_document.windows.json
}

resource "aws_iam_role" "windows" {
  name               = "windows_role"
  path               = "/"
  assume_role_policy = file("assume-policy.json")
  tags               = var.tags
}

resource "aws_iam_instance_profile" "windows_profile" {
  name = "windows"
  role = aws_iam_role.windows.name
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "windows" {
  role       = aws_iam_role.windows.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
