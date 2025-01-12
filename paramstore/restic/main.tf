terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "paramstore/restic"
    region = "us-east-1"
    encrypt = true
  }
}


resource "aws_ssm_parameter" "nas" {
  name  = "/restic/nas"
  type  = "SecureString"
  value = "placeholder"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
