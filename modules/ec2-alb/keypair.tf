# Key pairs using secrets
data "aws_secretsmanager_secret" "ec2_ssh_public_key" {
  name = "${var.environment}/ec2-ssh-public-key"
}

data "aws_secretsmanager_secret_version" "ec2_ssh_public_key" {
  secret_id = data.aws_secretsmanager_secret.ec2_ssh_public_key.id
}

data "aws_secretsmanager_secret" "nat_ssh_public_key" {
  name = "${var.environment}/nat-ssh-public-key"
}

data "aws_secretsmanager_secret_version" "nat_ssh_public_key" {
  secret_id = data.aws_secretsmanager_secret.nat_ssh_public_key.id
}
