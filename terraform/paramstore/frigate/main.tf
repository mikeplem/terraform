terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "paramstore/frigate"
    region = "us-east-1"
    encrypt = true
  }
}

resource "aws_ssm_parameter" "deck" {
  name  = "/frigate/deck"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "doorbell" {
  name  = "/frigate/doorbell"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}

resource "aws_ssm_parameter" "floodlight" {
  name  = "/frigate/floodlight"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
