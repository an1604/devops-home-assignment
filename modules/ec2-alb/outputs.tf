# Output the ALB DNS name
output "alb_dns_name" {
    description = "The DNS name of the load balancer"
    value       = aws_lb.moveo_alb.dns_name
} 

output "ec2_public_ip" {
    description = "The public IP address of the EC2 instance"
    value       = aws_instance.moveo_ec2.public_ip
}

output "ec2_private_ip" {
    description = "The private IP address of the EC2 instance"
    value       = aws_instance.moveo_ec2.private_ip
} 

# Outputs for EIPs
output "ssh_access_eip" {
    description = "The Elastic IP address for SSH access"
    value       = var.enable_eip_for_ssh ? aws_eip.ssh_access[0].public_ip : "EIP not enabled"
}

output "nat_instance_eip" {
    description = "The Elastic IP address of the NAT instance"
    value       = aws_eip.nat_instance.public_ip
} 

output "nat_instance_id" {
    description = "The ID of the NAT instance"
    value       = aws_instance.moveo_nat.id
}

output "nat_instance_private_ip" {
    description = "The private IP address of the NAT instance"
    value       = aws_instance.moveo_nat.private_ip
}

