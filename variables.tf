variable "region" {
  default = "us-east=1"
}

variable "ami" {
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {}

variable "environment" {}

variable "vpc_id" {}

variable "public_subnet_ids" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}
