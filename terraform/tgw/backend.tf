terraform {
  backend "s3" {
    bucket  = "plemmons-terraform-network"
    key     = "tgw/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
