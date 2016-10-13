resource "aws_instance" "api" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${element(module.vpc.public_subnet_ids, 1)}"
  user_data     = "${file("files/api_bootstrap.sh")}"
  vpc_security_group_ids = [
    "${aws_security_group.api_host_sg.id}"
  ]
  tags {
    Name = "${var.environment}-api-${count.index}"
  }
  count = 5
}

resource "aws_elb" "api" {
  name                = "${var.environment}-api-elb"
  subnets             = ["${element(module.vpc.public_subnet_ids, 1)}"]
  security_groups     = ["${aws_security_group.api_inbound_sg.id}"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  instances = ["${aws_instance.api.*.id}"]
}

resource "aws_security_group" "api_inbound_sg" {
  name        = "${var.environment}-api_inbound"
  description = "Allow API from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 1234
    to_port     = 1234
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "api_host_sg" {
  name        = "${var.environment}-api_host"
  description = "Allow SSH & HTTP to api hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 1234
    to_port     = 1234
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

