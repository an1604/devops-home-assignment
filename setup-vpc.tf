resource "aws_vpc" "moveo_vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    
    tags = {
        Name        = "${var.environment}-vpc"
        Environment = var.environment
        ManagedBy   = "Terraform"
        Security    = "High"
        Purpose     = "Production"
    }
}

data "aws_region" "current" {}

