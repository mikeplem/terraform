data "aws_iam_policy_document" "sandbox_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sandbox" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:Get*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "sandbox" {
  name   = "sandbox"
  role   = aws_iam_role.sandbox.id
  policy = data.aws_iam_policy_document.sandbox.json
}

resource "aws_iam_role" "sandbox" {
  name               = "sandbox_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sandbox_assume.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "sandbox" {
  name = "sandbox"
  role = aws_iam_role.sandbox.name
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sandbox" {
  role       = aws_iam_role.sandbox.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
