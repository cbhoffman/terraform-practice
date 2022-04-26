resource "aws_instance" "custom_instance" {
  ami           = data.aws_ami.most_recent_ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.custom_subnet.id
  key_name      = aws_key_pair.ec2_keypair.key_name
  vpc_security_group_ids = [aws_security_group.ssh_traffic.id]

  tags = {
    Name = "custom_instance"
  }
}

provider "tls" {
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2_keypair"
  public_key = tls_private_key.my_key.public_key_openssh
}