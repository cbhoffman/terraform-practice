resource "aws_secretsmanager_secret" "ec2_keypair_secret" {
  name = "custom_ec2_keypair_pem"
}

resource "aws_secretsmanager_secret_version" "ec2_keypair_secret_value" {
  secret_id     = aws_secretsmanager_secret.ec2_keypair_secret.id
  secret_string = tls_private_key.my_key.private_key_pem
}