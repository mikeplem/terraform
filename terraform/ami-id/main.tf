data "aws_ami" "al2_linux_x86" {
 most_recent = true

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

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

data "aws_ssm_parameter" "linux_arm64" {
  name = "/aws/service/debian/release/11/latest/arm64"
}

data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

output "al2023_x86_ami_id" {
  value = nonsensitive(data.aws_ssm_parameter.al2023_x86_64.value)
}

output "al2023_arm64_ami_id" {
  value = nonsensitive(data.aws_ssm_parameter.al2023_arm64.value)
}

output "al2_x86_ami_id" {
  value = data.aws_ami.al2_linux_x86.id
}

output "al2_arm_ami_id" {
  value = data.aws_ami.al2_linux_arm.id
}

output "debian_arm64" {
  value = nonsensitive(data.aws_ssm_parameter.linux_arm64.value)
}
