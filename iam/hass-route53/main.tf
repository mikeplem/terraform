resource "aws_iam_user" "hass" {
  name = "hass"
  path = "/"
}

resource "aws_iam_access_key" "hass" {
  user = aws_iam_user.hass.name
}

resource "aws_iam_user_policy" "hass" {
  name = "hass-r53"
  user = aws_iam_user.hass.name
  policy = file("policy.json")
}

resource "aws_ssm_parameter" "hass" {
  name  = "/iam/hass-r53"
  type  = "SecureString"
  value = jsonencode({"username"=aws_iam_access_key.hass.id,"password"=aws_iam_access_key.hass.secret})

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
