# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
  default     = "default"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "health_check_path" {
  description = "Health check path for the default target group"
  type        = string
  default     = "/"
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "moveo-ec2"
}

variable "ssh_pubkey_file" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "C:/ssh_keys/moveo_key_new.pub"
}

variable "ssh_pubkey_file_nat_instance" {
  description = "Path to the SSH public key file for the NAT instance"
  type        = string
  default     = "C:/ssh_keys/moveo_key_new_nat.pub"
}


variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  default     = "moveo-alb"
}


# Environment & Tagging
variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "moveo"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "moveo"
    Project     = "devops-assignment"
  }
}

# Security Configuration
variable "enable_eip_for_ssh" {
  description = "Whether to allocate an Elastic IP for SSH access"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access. Only used if enable_eip_for_ssh is false"
  type        = string
  default     = null  # will be overridden by EIP if enable_eip_for_ssh is true
}


