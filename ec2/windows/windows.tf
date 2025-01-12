data "aws_ami" "windows" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["EC2LaunchV2-Windows_Server-2019-English-Full-Base*"]  
  }

  filter {
   name   = "virtualization-type"
    values = ["hvm"]  
  }

  owners = ["801119661308"]
}

resource "aws_security_group" "windows" {
  name   = "windows-ec2"
  vpc_id = var.vpc_id

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

resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = "t3a.xlarge"
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  hibernation   = true

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = "windows"
  vpc_security_group_ids               = [aws_security_group.windows.id]

  user_data = null

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = false
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
    ignore_changes = [ami]
  }

  tags = var.tags

}
