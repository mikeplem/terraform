terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "iam/hass-route53"
    region = "us-east-1"
    encrypt = true
  }
}
