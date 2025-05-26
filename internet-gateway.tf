# Internet Gateway
resource "aws_internet_gateway" "moveo_igw" {
    vpc_id = aws_vpc.moveo_vpc.id

    tags = merge(var.tags, {
        Name = "${var.environment}-igw"
        Environment = var.environment
    })
}
