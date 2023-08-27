data "aws_organizations_organization" "this" {}

output "org" {
  value = data.aws_organizations_organization.this.arn
}

