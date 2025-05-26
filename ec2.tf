# Security Group for EC2 Instance
resource "aws_security_group" "moveo_ec2_security_group" {
    name        = "${var.environment}-ec2-security-group"
    description = "Security group for EC2 instance in private subnet"
    vpc_id      = aws_vpc.moveo_vpc.id

    # Allow inbound SSH from anywhere
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH from anywhere"
    }

    # Allow inbound HTTP from ALB only
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.moveo_alb_security_group.id]
        description     = "Allow HTTP from ALB only"
    }

    # Allow outbound traffic only to ALB
    egress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.moveo_alb_security_group.id]
        description     = "Allow outbound HTTP to ALB only"
    }

    tags = merge(var.tags, {
        Name = "${var.environment}-ec2-security-group"
        Environment = var.environment
    })
}

# IAM Role for EC2
resource "aws_iam_role" "moveo_ec2_role" {
    name = "${var.environment}-ec2-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = merge(var.tags, {
        Name        = "${var.environment}-ec2-role"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "moveo_ec2_profile" {
    name = "${var.environment}-ec2-profile"
    role = aws_iam_role.moveo_ec2_role.name
}

# EC2 Instance
resource "aws_instance" "moveo_ec2" {
    ami           = "ami-0c7217cdde317cfec"  # Amazon Linux 2023 AMI in us-east-1
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.moveo_public_subnet.id
    vpc_security_group_ids = [aws_security_group.moveo_ec2_security_group.id]
    iam_instance_profile = aws_iam_instance_profile.moveo_ec2_profile.name
    key_name      = aws_key_pair.terraform-lab.key_name

    # User data script to install Docker and run Nginx
    user_data = <<-EOF
        #!/bin/bash
        yum update -y
        
        yum install -y docker
        systemctl start docker
        systemctl enable docker
        
        docker run -d \
            --name nginx \
            -p 80:80 \
            -e NGINX_HOST=localhost \
            -e NGINX_PORT=80 \
            nginx:latest
            
        docker exec nginx sh -c 'echo "yo this is nginx" > /usr/share/nginx/html/index.html'
    EOF

    tags = merge(var.tags, {
        Name        = "${var.environment}-ec2"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })

    depends_on = [
        aws_security_group.moveo_ec2_security_group,
        aws_security_group.moveo_alb_security_group
    ]
}

# Add an output for the EC2 instance public IP
output "ec2_public_ip" {
    description = "The public IP address of the EC2 instance"
    value       = aws_instance.moveo_ec2.public_ip
} 