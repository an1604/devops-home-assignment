output "vpc_id" {
  value = aws_vpc.moveo_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.moveo_public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.moveo_private_subnet[*].id
}

output "private_route_table_id" {
  value = aws_route_table.moveo_private_rt.id
} 