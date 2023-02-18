data "aws_ami" "al2_linux_arm" {
 most_recent = true

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*arm*"]
 }
}

resource "aws_security_group" "rds_bastion" {
  name   = "rds_bastion-ec2"
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

resource "aws_instance" "rds_bastion" {
  ami           = data.aws_ami.al2_linux_arm.id
  instance_type = "t4g.micro"
  subnet_id     = var.subnet_id
  hibernation   = false
  key_name      = null

  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  iam_instance_profile                 = aws_iam_instance_profile.rds_bastion.name
  vpc_security_group_ids               = [aws_security_group.rds_bastion.id]

  user_data = file("userdata.sh")

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = merge({"Name"="boot","disk_role"="boot"},var.tags)
  }

  ebs_block_device {
    device_name           = "/dev/sdd"
    volume_size           = 16
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = merge({"Name"="ssm_log","disk_role"="ssm_log"},var.tags)
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
  value = aws_instance.rds_bastion.id
}

output "private_ip" {
  value = aws_instance.rds_bastion.private_ip
}
