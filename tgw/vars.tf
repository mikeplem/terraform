locals {
  vpc_tags = {
    ManagedBy = "Terraform"
  }
}

data "aws_organizations_organization" "this" {}
