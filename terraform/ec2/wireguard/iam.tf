data "aws_iam_policy_document" "wireguard_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "wireguard" {
  name               = "wireguard_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.wireguard_assume.json
  tags               = var.tags
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
