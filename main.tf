data "aws_vpc" "environment" {
  id = var.vpc_id
}

resource "aws_instance" "api" {
  ami           = var.ami[var.region]
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_ids[1]
  user_data     = file("${path.module}/files/api_bootstrap.sh")

  vpc_security_group_ids = [
    aws_security_group.api_host_sg.id,
  ]

  tags = {
    Name = "${var.environment}-api-${count.index}"
  }

  count = var.api_instance_count
}

resource "aws_elb" "api" {
  name = "${var.environment}-api-elb"
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnets         = [var.public_subnet_ids[1]]
  security_groups = [aws_security_group.api_inbound_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = aws_instance.api.*.id
}

resource "aws_security_group" "api_inbound_sg" {
  name        = "${var.environment}-api-inbound"
  description = "Allow API from Anywhere"
  vpc_id      = data.aws_vpc.environment.id

  ingress {
    from_port   = 80
    to_port     = 80
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

  tags = {
    Name = "${var.environment}-api-inbound-sg"
  }
}

resource "aws_security_group" "api_host_sg" {
  name        = "${var.environment}-api-host"
  description = "Allow SSH and HTTP to api hosts"
  vpc_id      = data.aws_vpc.environment.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.environment.cidr_block]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.environment.cidr_block]
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

  tags = {
    Name = "${var.environment}-api-host-sg"
  }
}

