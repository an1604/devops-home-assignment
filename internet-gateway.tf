# Internet Gateway
resource "aws_internet_gateway" "moveo_igw" {
    vpc_id = aws_vpc.moveo_vpc.id

    tags = {
        Name = "${var.environment}-igw"
        
    }
}
