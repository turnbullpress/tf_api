variable "region" {
  type        = string
  description = "The AWS region."
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "The name of our environment, i.e. development."
}

variable "key_name" {
  type        = string
  description = "The AWS key pair to use for resources."
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = []
  description = "The list of public subnets to populate."
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "The list of private subnets to populate."
}

variable "ami" {
  type = map(string)
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
    "eu-west-1" = "ami-0ae77879"
  }

  description = "The AMIs to use for API instances."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The instance type to launch "
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch in"
}

variable "api_instance_count" {
  type        = number
  default     = 5
  description = "The number of API instances to launch."
}

output "api_elb_address" {
  value = aws_elb.api.dns_name
}

output "api_host_addresses" {
  value = aws_instance.api[*].private_ip
}

