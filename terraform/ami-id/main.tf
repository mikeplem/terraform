data "aws_ami" "linux" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["*debian*"]
  }

  filter {
   name   = "virtualization-type"
    values = ["hvm"]  
  }

  owners = ["136693071363"]
}

data "aws_ssm_parameter" "linux_amd64" {
  name = "/aws/service/debian/release/11/latest/amd64"
}

data "aws_ssm_parameter" "linux_arm64" {
  name = "/aws/service/debian/release/11/latest/arm64"
}

output "ami_id" {
    value = data.aws_ami.linux.id
}

output "ssm_amd64" {
    value = nonsensitive(data.aws_ssm_parameter.linux_amd64.value)
}

output "ssm_arm64" {
    value = nonsensitive(data.aws_ssm_parameter.linux_arm64.value)
}
