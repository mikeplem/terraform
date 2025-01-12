terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "iam/ssm-session"
    region = "us-east-1"
    encrypt = true
  }
}
