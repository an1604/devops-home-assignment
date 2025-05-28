# # Create secrets for SSH public keys
# resource "aws_secretsmanager_secret" "ec2_ssh_public_key" {
#   name        = "${var.environment}/ec2-ssh-public-key"
#   description = "SSH public key for EC2 instance"
  
#   tags = merge(var.tags, {
#     Name        = "${var.environment}-ec2-ssh-key-secret"
#     Environment = var.environment
#     ManagedBy   = "Terraform"
#   })
# }

# resource "aws_secretsmanager_secret_version" "ec2_ssh_public_key" {
#   secret_id     = aws_secretsmanager_secret.ec2_ssh_public_key.id
#   secret_string = var.ssh_public_key_value
# }

# resource "aws_secretsmanager_secret" "nat_ssh_public_key" {
#   name        = "${var.environment}/nat-ssh-public-key"
#   description = "SSH public key for NAT instance"
  
#   tags = merge(var.tags, {
#     Name        = "${var.environment}-nat-ssh-key-secret"
#     Environment = var.environment
#     ManagedBy   = "Terraform"
#   })
# }

# resource "aws_secretsmanager_secret_version" "nat_ssh_public_key" {
#   secret_id     = aws_secretsmanager_secret.nat_ssh_public_key.id
#   secret_string = var.ssh_public_key_nat_value
# }

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
  
