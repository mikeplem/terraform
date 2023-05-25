terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "route53/n1mtp_com"
    region = "us-east-1"
    encrypt = true
  }
}
