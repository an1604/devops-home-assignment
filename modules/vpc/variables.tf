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


