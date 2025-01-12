data "aws_iam_policy_document" "rds_bastion_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_bastion" {
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

resource "aws_iam_role_policy" "rds_bastion" {
  name   = "rds_bastion"
  role   = aws_iam_role.rds_bastion.id
  policy = data.aws_iam_policy_document.rds_bastion.json
}

resource "aws_iam_role" "rds_bastion" {
  name               = "rds_bastion_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_bastion_assume.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "rds_bastion" {
  name = "rds_bastion"
  role = aws_iam_role.rds_bastion.name
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_bastion" {
  role       = aws_iam_role.rds_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "rds_bastion_logs" {
  role       = aws_iam_role.rds_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
