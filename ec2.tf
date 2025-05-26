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
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic through NAT"
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

# IAM Policy Document for EC2
data "aws_iam_policy_document" "moveo_ec2_policy_doc" {
    statement {
        actions = [
            "ec2:*",
            "elasticloadbalancing:*",
            "cloudwatch:*",
            "autoscaling:*"
        ]
        effect    = "Allow"
        resources = ["*"]
    }

    statement {
        actions = ["iam:CreateServiceLinkedRole"]
        effect  = "Allow"
        resources = ["*"]
        condition {
            test     = "StringEquals"
            variable = "iam:AWSServiceName"
            values = [
                "autoscaling.amazonaws.com",
                "ec2scheduled.amazonaws.com",
                "elasticloadbalancing.amazonaws.com",
                "spot.amazonaws.com",
                "spotfleet.amazonaws.com",
                "transitgateway.amazonaws.com"
            ]
        }
    }
}

# IAM Policy
resource "aws_iam_policy" "moveo_ec2_policy" {
    name        = "${var.environment}-ec2-policy"
    description = "Policy for EC2 instance to access AWS services"
    policy      = data.aws_iam_policy_document.moveo_ec2_policy_doc.json

    tags = merge(var.tags, {
        Name        = "${var.environment}-ec2-policy"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "moveo_ec2_policy_attachment" {
    role       = aws_iam_role.moveo_ec2_role.name
    policy_arn = aws_iam_policy.moveo_ec2_policy.arn
}

# EC2 Instance
resource "aws_instance" "moveo_ec2" {
    ami           = "ami-0c7217cdde317cfec"  # Amazon Linux 2023 AMI in us-east-1
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.moveo_private_subnet[0].id  # Using the first private subnet
    vpc_security_group_ids = [aws_security_group.moveo_ec2_security_group.id]
    iam_instance_profile = aws_iam_instance_profile.moveo_ec2_profile.name
    key_name      = aws_key_pair.terraform-lab.key_name

    # User data script to install Docker and run Nginx
    user_data = <<-EOF
        #!/bin/bash
        sudo apt update 
        sudo apt install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
        
        sudo docker run -d \
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
        aws_security_group.moveo_alb_security_group,
        aws_key_pair.terraform-lab
    ]
}

# Add an output for the EC2 instance public IP
output "ec2_public_ip" {
    description = "The public IP address of the EC2 instance"
    value       = aws_instance.moveo_ec2.public_ip
}

output "ec2_private_ip" {
    description = "The private IP address of the EC2 instance"
    value       = aws_instance.moveo_ec2.private_ip
} 