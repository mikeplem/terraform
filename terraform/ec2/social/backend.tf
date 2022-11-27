terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "ec2/social"
    region = "us-east-1"
    encrypt = true
  }
}
