variable "vpc_id" {
	default = "vpc-f92f209c"
}

variable "subnet_id" {
	default = "subnet-ef7c0cb6"
}

variable "key_name" {
	default = "AWSKeyPair"
}

variable "tags" {
	default = {
		"Name" = "windows"
	}
}