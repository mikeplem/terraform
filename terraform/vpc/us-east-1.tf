provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# ----------

data "aws_vpc_ipam_pool" "ipv4_us_east_1" {
  filter {
    name   = "locale"
    values = ["us-east-1"]
  }

  filter {
    name   = "address-family"
    values = ["ipv4"]
  }

  filter {
    name   = "ipam-scope-type"
    values = ["private"]
  }

  provider = aws.us-east-1
}

data "aws_vpc_ipam_preview_next_cidr" "us_east_1_next_cidr" {
  ipam_pool_id   = data.aws_vpc_ipam_pool.ipv4_us_east_1.id
  netmask_length = 24
  provider       = aws.us-east-1
}

data "aws_region" "current_us_east_1" {
  provider = aws.us-east-1
}

# ----------

locals {
  us_east_1_az_subnets = cidrsubnets(data.aws_vpc_ipam_preview_next_cidr.us_east_1_next_cidr.cidr, 1, 1)
  us_east_1_az_one     = cidrsubnets(local.us_east_1_az_subnets[0], 2, 2, 2, 2)
  us_east_1_az_two     = cidrsubnets(local.us_east_1_az_subnets[1], 2, 2, 2, 2)

  us_east_1_intra_public_subnets_az_one = cidrsubnets(local.us_east_1_az_one[0], 1, 1)
  us_east_1_intra_subnets_az_one        = local.us_east_1_intra_public_subnets_az_one[0]
  us_east_1_public_subnets_az_one       = local.us_east_1_intra_public_subnets_az_one[1]
  us_east_1_private_subnets_az_one      = local.us_east_1_az_one[1]
  us_east_1_db_subnets_az_one           = local.us_east_1_az_one[2]
  us_east_1_redis_subnets_az_one        = local.us_east_1_az_one[3]

  us_east_1_intra_public_subnets_az_two = cidrsubnets(local.us_east_1_az_two[0], 1, 1)
  us_east_1_intra_subnets_az_two        = local.us_east_1_intra_public_subnets_az_two[0]
  us_east_1_public_subnets_az_two       = local.us_east_1_intra_public_subnets_az_two[1]
  us_east_1_private_subnets_az_two      = local.us_east_1_az_two[1]
  us_east_1_db_subnets_az_two           = local.us_east_1_az_two[2]
  us_east_1_redis_subnets_az_two        = local.us_east_1_az_two[3]
}

# ----------

resource "aws_eip" "nat_us_east_1" {
  count    = 2
  domain   = "vpc"
  provider = aws.us-east-1
}

module "us_east_1" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = aws.us-east-1
  }

  name = "us_east_1"
  cidr = data.aws_vpc_ipam_preview_next_cidr.us_east_1_next_cidr.cidr

  azs = formatlist("${data.aws_region.current_us_east_1.name}%s", ["a", "b"])

  intra_subnets = [
    local.us_east_1_intra_subnets_az_one,
    local.us_east_1_intra_subnets_az_two
  ]

  public_subnets = [
    local.us_east_1_public_subnets_az_one,
    local.us_east_1_public_subnets_az_two
  ]

  private_subnets = [
    local.us_east_1_private_subnets_az_one,
    local.us_east_1_private_subnets_az_two
  ]

  database_subnets = [
    local.us_east_1_db_subnets_az_one,
    local.us_east_1_db_subnets_az_two
  ]

  elasticache_subnets = [
    local.us_east_1_redis_subnets_az_one,
    local.us_east_1_redis_subnets_az_two
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  reuse_nat_ips          = true                       # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids    = aws_eip.nat_us_east_1.*.id # <= IPs specified here as input to the module

  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false
  enable_vpn_gateway              = false

  create_database_subnet_route_table    = true
  create_elasticache_subnet_route_table = true
  create_redshift_subnet_route_table    = false

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  # create_flow_log_cloudwatch_iam_role = true
  # create_flow_log_cloudwatch_log_group = true
  # enable_flow_log = true

  igw_tags = merge(local.vpc_tags, {
    "Description" = "Internet Gateway"
  })
  nat_eip_tags = merge(local.vpc_tags, {
    "Description" = "Managed NAT Gateway Elastic IP"
  })
  nat_gateway_tags = merge(local.vpc_tags, {
    "Description" = "Managed NAT Gateway"
  })
  private_acl_tags = merge(local.vpc_tags, {
    "aclRole" = "private",
    "Name"    = "private"
  })
  private_route_table_tags = merge(local.vpc_tags, {
    "routeRole"      = "private",
    "Name"           = "private",
    "Associate-with" = "Infrastructure",
    "Propagate-to"   = "Infrastructure"
  })
  private_subnet_tags = merge(local.vpc_tags, {
    "subnetRole"    = "private",
    "Name"          = "private",
    "Attach-to-tgw" = "",
    "Route-to-tgw"  = ""
  })
  public_acl_tags = merge(local.vpc_tags, {
    "aclRole" = "public",
    "Name"    = "public"
  })
  public_route_table_tags = merge(local.vpc_tags, {
    "routeRole" = "public",
    "Name"      = "public"
  })
  public_subnet_tags = merge(local.vpc_tags, {
    "subnetRole" = "public",
    "Name"       = "public"
  })
  intra_acl_tags = merge(local.vpc_tags, {
    "aclRole" = "intra",
    "Name"    = "intra"
  })
  intra_route_table_tags = merge(local.vpc_tags, {
    "routeRole" = "intra",
    "Name"      = "intra"
  })
  intra_subnet_tags = merge(local.vpc_tags, {
    "subnetRole" = "intra",
    "Name"       = "intra"
  })
  vpc_tags = merge(local.vpc_tags, {
    "vpcRole"        = "custom",
    "Associate-with" = "Infrastructure",
    "Propagate-to"   = "Infrastructure"
  })
  tags = local.vpc_tags

  # database_acl_tags            = merge(local.vpc_tags, { "aclRole" = "database", "Name" = "rds" })
  # database_route_table_tags    = merge(local.vpc_tags, { "routeRole" = "database", "Name" = "rds" })
  # database_subnet_tags         = merge(local.vpc_tags, { "subnetRole" = "database", "Name" = "rds" })
  # elasticache_acl_tags         = merge(local.vpc_tags, { "aclRole" = "elasticache", "Name" = "redis" })
  # elasticache_route_table_tags = merge(local.vpc_tags, { "routeRole" = "elasticache", "Name" = "redis" })
  # elasticache_subnet_tags      = merge(local.vpc_tags, { "subnetRole" = "elasticache", "Name" = "redis" })
}
