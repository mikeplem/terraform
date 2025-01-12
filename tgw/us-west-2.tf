provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

module "tgw_us_west_2" {
  depends_on = [module.us_west_2]
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.10.0"

  amazon_side_asn = "64529"
  name        = "us-west-2"
  description = "us-west-2 transit gateway"

  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = true
  enable_default_route_table_propagation = true
  enable_vpn_ecmp_support = false

  vpc_attachments = {
    vpc = {
      vpc_id       = module.us_west_2.vpc_id
      subnet_ids   = module.us_west_2.private_subnets
      dns_support  = true
      ipv6_support = false

      tgw_routes = [
        {
          blackhole = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    }
  }

  ram_allow_external_principals = false
  ram_principals = [data.aws_organizations_organization.this.arn]

  tags = local.vpc_tags

  ram_tags = merge(local.vpc_tags, {
    "Name" = "us-west-2 tgw",
    "Region" = "us-west-2"
  })

  tgw_tags = merge(local.vpc_tags, {
    "Name" = "us-west-2 tgw",
    "Region" = "us-west-2",
    # "TgwPeer" = "tgw-0d97f24bfe6644ab4_us-east-1/tgw-0f38615fd992feea8_us-west-2"
  })

  providers = {
    aws = aws.us-west-2
  }
}
