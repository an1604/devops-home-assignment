output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.ec2-alb.alb_dns_name
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2-alb.ec2_public_ip
}

output "ec2_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.ec2-alb.ec2_private_ip
}

output "ssh_access_eip" {
  description = "The Elastic IP address for SSH access"
  value       = module.ec2-alb.ssh_access_eip
}

output "nat_instance_eip" {
  description = "The Elastic IP address of the NAT instance"
  value       = module.ec2-alb.nat_instance_eip
}

output "nat_instance_id" {
  description = "The ID of the NAT instance"
  value       = module.ec2-alb.nat_instance_id
}

output "nat_instance_private_ip" {
  description = "The private IP address of the NAT instance"
  value       = module.ec2-alb.nat_instance_private_ip
}
