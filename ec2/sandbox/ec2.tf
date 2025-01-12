variable "tags" {
  default = {
    "Name" = "sandbox"
  }
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_vpc" "sandbox" {}

data "aws_subnets" "sandbox" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.sandbox.id]
  }
}

resource "aws_security_group" "sandbox" {
  name   = "sandbox-ec2"
  vpc_id = data.aws_vpc.sandbox.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

}

resource "aws_instance" "sandbox" {
  ami           = nonsensitive(data.aws_ssm_parameter.al2023.value)
  instance_type = "t3.medium"
  subnet_id     = element(data.aws_subnets.sandbox.ids, 0)
  hibernation   = false
  key_name      = null

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = aws_iam_instance_profile.sandbox.name
  vpc_security_group_ids               = [aws_security_group.sandbox.id]

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

  tags = var.tags

}

output "instance_id" {
  value = aws_instance.sandbox.id
}

output "private_ip" {
  value = aws_instance.sandbox.private_ip
}
