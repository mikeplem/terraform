variable "vpc_id" {
  default = "vpc-f92f209c"
}

variable "subnet_id" {
  default = "subnet-b9229bb5"
}

variable "tags" {
  default = {
    "Name" = "rds_bastion"
  }
}