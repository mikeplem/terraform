terraform {
  backend "s3" {
    bucket = "plemmons-terraform-sandbox"
    key    = "ec2/sandbox"
    region = "us-east-1"
    encrypt = true
  }
}
