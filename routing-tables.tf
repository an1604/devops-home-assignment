# Public Route Table
resource "aws_route_table" "moveo_public_rt" {
    vpc_id = aws_vpc.moveo_vpc.id

    route {
        cidr_block = "0.0.0.0/0" # All traffic
        gateway_id = aws_internet_gateway.moveo_igw.id # routing all traffic to the Internet Gateway
    }

    tags = {
        Name = "${var.environment}-public-rt"
        ManagedBy = "Terraform"
        Purpose = "Public"
    }
}

# Private Route Table
resource "aws_route_table" "moveo_private_rt" {
    vpc_id = aws_vpc.moveo_vpc.id
    depends_on = [ aws_nat_gateway.moveo_nat ] # ensuring NAT Gateway is created before private route table

    route {
        cidr_block = "0.0.0.0/0" # All traffic
        nat_gateway_id = aws_nat_gateway.moveo_nat.id # routing all traffic to the NAT Gateway
    }
    
    tags = {
        Name = "${var.environment}-private-rt"
        ManagedBy = "Terraform"
        Purpose = "Private"
    }
}

