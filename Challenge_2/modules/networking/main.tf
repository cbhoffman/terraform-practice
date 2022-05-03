variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = "us-east-1a"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "custom_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  availability_zone       = var.availability_zone
  cidr_block              = cidrsubnet(var.cidr_block, 8, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "custom_subnet"
  }
}

resource "aws_route_table" "custom_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name = "custom_route_table"
  }
}

resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom_igw"
  }
}

resource "aws_security_group" "ssh_traffic" {
  name        = "ssh_traffic"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "SSH traffic to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_traffic"
  }
}

resource "aws_main_route_table_association" "custom_rt_a" {
  vpc_id         = aws_vpc.custom_vpc.id
  route_table_id = aws_route_table.custom_route_table.id
}