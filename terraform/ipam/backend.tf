terraform {
  backend "s3" {
    bucket = "plemmons-terraform-network"
    key    = "ipam/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
