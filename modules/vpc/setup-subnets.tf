# Public Subnets
resource "aws_subnet" "moveo_public_subnet" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.moveo_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
    map_public_ip_on_launch = true
    availability_zone = var.availability_zones[count.index]

    tags = merge(var.tags, {
        Name = "${var.environment}-public-subnet-${count.index + 1}"
        Environment = var.environment
        ManagedBy = "Terraform"
        Purpose = "Public"
    })
}

# Private Subnets
resource "aws_subnet" "moveo_private_subnet" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.moveo_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
    map_public_ip_on_launch = false
    availability_zone = var.availability_zones[count.index]

    tags = merge(var.tags, {
        Name = "${var.environment}-private-subnet-${count.index + 1}"
        Environment = var.environment
        ManagedBy = "Terraform"
        Purpose = "Private"
    })
}


