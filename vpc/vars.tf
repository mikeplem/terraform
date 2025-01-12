locals {
  vpc_tags = {
    ManagedBy = "Terraform"
  }
}

data "aws_organizations_organization" "this" {}

# ===============

# VPC - 10.1.4.0/24

# > cidrsubnets("10.1.4.0/24", 1, 1)
# tolist([
#   "10.1.4.0/25",
#   "10.1.4.128/25",
# ])

# AZ 1 - 10.1.4.0/25

# > cidrsubnets("10.1.4.0/25", 2, 2, 2, 2)
# tolist([
#   "10.1.4.0/27", - broken out into 2 /28s
#   "10.1.4.32/27",
#   "10.1.4.64/27",
#   "10.1.4.96/27",
# ])

# > cidrsubnets("10.1.4.0/27", 1, 1)
# tolist([
#   "10.1.4.0/28",
#   "10.1.4.16/28",
# ])

# intra_subnets - 10.1.4.0/28 - 14 hosts
# public_subnets - 10.1.4.16/28 - 14 hosts
# private_subnets - 10.1.4.32/27 - 30 hosts
# database_subnets - 10.1.4.64/27 - 30 hosts
# elasticache_subnets - 10.1.4.96/27 - 30 hosts

# AZ 2 - 10.1.4.128/25

# > cidrsubnets("10.1.4.128/25", 2, 2, 2, 2)
# tolist([
#   "10.1.4.128/27",
#   "10.1.4.160/27",
#   "10.1.4.192/27",
#   "10.1.4.224/27",
# ])

# > cidrsubnets("10.1.4.128/27", 1, 1)
# tolist([
#   "10.1.4.128/28",
#   "10.1.4.144/28",
# ])

# intra_subnets - 10.1.4.128/28 - 14 hosts
# public_subnets - 10.1.4.144/28 - 14 hosts
# private_subnets - 10.1.4.160/27 - 30 hosts
# database_subnets - 10.1.4.192/27 - 30 hosts
# elasticache_subnets - 10.1.4.224/27 - 30 hosts
