# Public Route Table Associations
resource "aws_route_table_association" "moveo_public_rt_association" {
    count = length(var.availability_zones)
    subnet_id = aws_subnet.moveo_public_subnet[count.index].id
    route_table_id = aws_route_table.moveo_public_rt.id
    depends_on = [aws_route_table.moveo_public_rt, aws_subnet.moveo_public_subnet]
}

# Private Route Table Associations
resource "aws_route_table_association" "moveo_private_rt_association" {
    count = length(var.availability_zones)
    subnet_id = aws_subnet.moveo_private_subnet[count.index].id
    route_table_id = aws_route_table.moveo_private_rt.id
    depends_on = [aws_route_table.moveo_private_rt, aws_subnet.moveo_private_subnet]
}
