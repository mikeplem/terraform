terraform {
  backend "s3" {
    bucket = "plemmons-terraform"
    key    = "rds/rds_bastion"
    region = "us-east-1"
    encrypt = true
  }
}
