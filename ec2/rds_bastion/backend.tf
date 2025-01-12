terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "ec2/rds_bastion"
    region = "us-east-1"
    encrypt = true
  }
}
