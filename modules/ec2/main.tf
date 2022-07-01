resource "aws_instance" "custom_instance" {
  ami                    = data.aws_ami.most_recent_ami.id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.ec2_keypair.key_name
  vpc_security_group_ids = var.security_group_ids
  user_data              = <<EOF
  #!/bin/bash 
  sudo amazon-linux-extras install nginx1 -y
  sudo echo "<h2>Hello World!</h2>" > /usr/share/nginx/html/index.html
  sudo systemctl start nginx.service
  EOF

  tags = {
    Name = var.instance_name
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2_keypair"
  public_key = tls_private_key.my_key.public_key_openssh
}

data "aws_ami" "most_recent_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}

resource "aws_secretsmanager_secret" "ec2_keypair_secret" {
  name = "custom_ec2_keypair_pem"
}

resource "aws_secretsmanager_secret_version" "ec2_keypair_secret_value" {
  secret_id     = aws_secretsmanager_secret.ec2_keypair_secret.id
  secret_string = tls_private_key.my_key.private_key_pem
}