# Public Subnet
resource "aws_subnet" "moveo_public_subnet" {
    vpc_id = aws_vpc.moveo_vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone

    tags = {
        Name = "${var.environment}-public-subnet"
        Environment = var.environment
        ManagedBy = "Terraform"
        Purpose = "Public"
    }
}

# Private Subnet
resource "aws_subnet" "moveo_private_subnet" {
    vpc_id = aws_vpc.moveo_vpc.id
    cidr_block = var.private_subnet_cidr
    map_public_ip_on_launch = false
    availability_zone = var.availability_zone

    tags = {
        Name = "${var.environment}-private-subnet"
        Environment = var.environment
        ManagedBy = "Terraform"
        Purpose = "Private"
    }
}


