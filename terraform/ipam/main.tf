data "aws_regions" "current" {
  all_regions = true

  filter {
    name = "opt-in-state"
    values = ["not-opted-in"]
  }
}

resource "aws_vpc_ipam"



# module "ipam" {
#   source  = "aws-ia/ipam/aws"
#   version = "2.0.0"

#   create_ipam = true
#   top_cidr = ["10.0.0.0/8"]
#   top_name = "parent pool"

#   pool_configurations = {
#     us-east-1 = {
#       description = "locale us-east-1 pool"
#       cidr        = ["10.1.0.0/16"]
#       locale      = "us-east-1"
#       ram_share_principals = ["arn:aws:organizations::568644839092:organization/o-xi4oyvzaiv"]
#       tags = {
#         Name = "us-east-1"
#         ManagedBy = "Terraform"
#         Region = "us-east-1"
#       }
#     }
#     us-east-2 = {
#       description = "locale us-east-2 pool"
#       cidr        = ["10.2.0.0/16"]
#       locale      = "us-east-2"
#       ram_share_principals = ["arn:aws:organizations::568644839092:organization/o-xi4oyvzaiv"]
#       tags = {
#         Name = "us-east-2"
#         ManagedBy = "Terraform"
#         Region = "us-east-2"
#       }
#     }
#     us-west-2 = {
#       description = "locale us-east-2 pool"
#       cidr        = ["10.3.0.0/16"]
#       locale      = "us-west-2"
#       ram_share_principals = ["arn:aws:organizations::568644839092:organization/o-xi4oyvzaiv"]
#       tags = {
#         Name = "us-west-2"
#         ManagedBy = "Terraform"
#         Region = "us-west-2"
#       }
#     }
#   }

#   tags = {
#     Name = "ParentIPv4Pool"
#     ManagedBy = "Terraform"
#   }
# }
