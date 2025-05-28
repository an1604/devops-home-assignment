module "vpc" {
    source = "./modules/vpc"
    aws_region = var.aws_region
    aws_profile = var.aws_profile
    vpc_cidr = var.vpc_cidr
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    availability_zones = var.availability_zones
    health_check_path = var.health_check_path
    environment = var.environment
    tags = var.tags
}

module "ec2-alb" {
    source = "./modules/ec2-alb"
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
    private_subnet_ids = module.vpc.private_subnet_ids
    private_route_table_id = module.vpc.private_route_table_id
    enable_eip_for_ssh = var.enable_eip_for_ssh
    allowed_ssh_cidr = var.allowed_ssh_cidr
    environment = var.environment
    tags = var.tags
}

# Configure Terraform backend
terraform {
  backend "s3" {
    bucket         = "moveo-terraform-state-2024"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

