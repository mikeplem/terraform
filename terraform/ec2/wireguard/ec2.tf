data "aws_ssm_parameter" "linux_arm64" {
  name = "/aws/service/debian/release/12/latest/arm64"
}

data "aws_vpc" "us_east_2" {}

data "aws_subnets" "us_east_2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.us_east_2.id]
  }
}

resource "aws_security_group" "wireguard" {
  name   = "wireguard-ec2"
  vpc_id = data.aws_vpc.us_east_2.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

}

resource "aws_instance" "wireguard" {
  ami           = nonsensitive(data.aws_ssm_parameter.linux_arm64.value)
  instance_type = "t4g.medium"
  subnet_id     = data.aws_subnets.us_east_2.ids[0]
  hibernation   = false

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = aws_iam_instance_profile.wireguard.name
  vpc_security_group_ids               = [aws_security_group.wireguard.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = merge({"Name"="boot","disk_role"="boot"},var.tags)
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  lifecycle {
    ignore_changes = [ami, user_data]
  }

  tags = var.tags

}

resource "aws_eip" "wireguard" {
  instance = aws_instance.wireguard.id
  domain   = "vpc"
  tags     = var.tags
}

resource "aws_eip_association" "wireguard" {
  instance_id   = aws_instance.wireguard.id
  allocation_id = aws_eip.wireguard.id
}

output "instance_id" {
  value = aws_instance.wireguard.id
}

output "private_ip" {
  value = aws_instance.wireguard.private_ip
}

output "public_ip" {
  value = aws_eip.wireguard.public_ip
}
