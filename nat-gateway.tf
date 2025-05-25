# Elastic IP for NAT Gateway
resource "aws_eip" "moveo_eip" {
    domain = "vpc"

    tags = {
        Name = "${var.environment}-eip"
    }
}

# NAT Gateway
resource "aws_nat_gateway" "moveo_nat" {
    allocation_id = aws_eip.moveo_eip.id
    depends_on = [ aws_eip.moveo_eip ] # ensuring EIP is created before NAT Gateway
    subnet_id = aws_subnet.moveo_public_subnet.id
    
    tags = {
        Name = "${var.environment}-nat"
    }
}

