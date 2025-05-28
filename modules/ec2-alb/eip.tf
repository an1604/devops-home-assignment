# Elastic IP for SSH access (management)
resource "aws_eip" "ssh_access" {
    count    = var.enable_eip_for_ssh ? 1 : 0
    domain   = "vpc"
    
    tags = merge(var.tags, {
        Name        = "${var.environment}-ssh-access-eip"
        Environment = var.environment
        ManagedBy   = "Terraform"
        Purpose     = "SSH Access"
    })
}

# Elastic IP for NAT Instance
resource "aws_eip" "nat_instance" {
    domain   = "vpc"
    instance = aws_instance.moveo_nat.id
    
    tags = merge(var.tags, {
        Name        = "${var.environment}-nat-eip"
        Environment = var.environment
        ManagedBy   = "Terraform"
        Purpose     = "NAT Instance"
    })
}

