terraform {
  backend "s3" {
    bucket  = "plemmons-terraform-sandbox"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
