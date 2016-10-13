variable "region" {
  default = "us-east=1"
}

variable "ami" {
  type    = "map"
  default = {}
}
variable "instance_type" {
  default = "t2.micro"
}
variable "key_name" {}
variable "environment" {}
