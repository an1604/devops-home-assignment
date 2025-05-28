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

resource "aws_key_pair" "terraform-lab" {
  key_name   = "${var.environment}_new_key_pair"
  public_key = data.aws_secretsmanager_secret_version.ec2_ssh_public_key.secret_string
}

resource "aws_key_pair" "nat-instance-key-pair" {
  key_name   = "${var.environment}_nat_instance_key_pair"
  public_key = data.aws_secretsmanager_secret_version.nat_ssh_public_key.secret_string
}