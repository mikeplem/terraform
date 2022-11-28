data "aws_ssm_parameter" "linux_arm64" {
  name = "/aws/service/debian/release/11/latest/arm64"
}

resource "aws_security_group" "social" {
  name   = "social-ec2"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

}

resource "aws_instance" "social" {
  ami           = nonsensitive(data.aws_ssm_parameter.linux_arm64.value)
  instance_type = "t4g.medium"
  subnet_id     = var.subnet_id
  hibernation   = false
  key_name      = "AWSKeyPair"

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = aws_iam_instance_profile.social.name
  vpc_security_group_ids               = [aws_security_group.social.id]

  user_data = file("userdata.sh")

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = merge({"Name"="boot","disk_role"="boot"},var.tags)
  }

  ebs_block_device {
    device_name           = "/dev/sdd"
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = merge({"Name"="db","disk_role"="db"},var.tags)
  }

  ebs_block_device {
    device_name           = "/dev/sde"
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = merge({"Name"="mastadon","disk_role"="mastadon"},var.tags)
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

resource "aws_eip" "social" {
  instance = aws_instance.social.id
  vpc      = true
  tags     = var.tags
}

resource "aws_eip_association" "social" {
  instance_id   = aws_instance.social.id
  allocation_id = aws_eip.social.id
}

output "instance_id" {
  value = aws_instance.social.id
}

output "private_ip" {
  value = aws_instance.social.private_ip
}

output "public_ip" {
  value = aws_eip.social.public_ip
}
