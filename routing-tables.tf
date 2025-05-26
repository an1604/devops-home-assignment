# Public Route Table
resource "aws_route_table" "moveo_public_rt" {
    vpc_id = aws_vpc.moveo_vpc.id

    route {
        cidr_block = "0.0.0.0/0" # All traffic
        gateway_id = aws_internet_gateway.moveo_igw.id # routing all traffic to the Internet Gateway
    }

    tags = merge(var.tags, {
        Name = "${var.environment}-public-rt"
        Environment = var.environment
        ManagedBy = "Terraform"
        Purpose = "Public"
    })
}

# Private Route Table
resource "aws_route_table" "moveo_private_rt" {
    vpc_id = aws_vpc.moveo_vpc.id
    
    tags = merge(var.tags, {
        Name = "${var.environment}-private-rt"
        Environment = var.environment
        ManagedBy = "Terraform"
        Purpose = "Private"
    })
}

