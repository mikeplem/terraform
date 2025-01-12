data "aws_iam_policy_document" "wireguard_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "wireguard_s3" {
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
      "arn:aws:s3:::plemmons-wireguard",
      "arn:aws:s3:::plemmons-wireguard/*",
    ]
  }
}

resource "aws_iam_role" "wireguard" {
  name               = "wireguard_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.wireguard_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "wireguard" {
  name   = "wireguard"
  role   = aws_iam_role.wireguard.id
  policy = data.aws_iam_policy_document.wireguard_s3.json
}

resource "aws_iam_instance_profile" "wireguard" {
  name = "wireguard"
  role = aws_iam_role.wireguard.name
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "wireguard" {
  role       = aws_iam_role.wireguard.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
