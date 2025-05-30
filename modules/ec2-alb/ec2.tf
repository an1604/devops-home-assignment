# Security Group for EC2 Instance
resource "aws_security_group" "moveo_ec2_security_group" {
    name        = "${var.environment}-ec2-security-group"
    description = "Security group for EC2 instance in private subnet"
    vpc_id      = var.vpc_id

    # Allow inbound SSH based on configuration
    dynamic "ingress" {
        for_each = var.enable_eip_for_ssh ? [] : [1]
        content {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = [var.allowed_ssh_cidr]
            description = "Allow SSH from specified CIDR"
        }
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
        security_groups = [aws_security_group.moveo_nat_security_group.id]
        description     = "Allow outbound HTTP traffic to NAT instance"
    }

    egress {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        security_groups = [aws_security_group.moveo_nat_security_group.id]
        description     = "Allow outbound HTTPS traffic to NAT instance"
    }

    # Allow outbound traffic only to ALB
    egress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.moveo_alb_security_group.id]
        description     = "Allow outbound HTTP traffic to ALB"
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
        actions = [
            "secretsmanager:GetSecretValue"
        ]
        effect    = "Allow"
        resources = [
            data.aws_secretsmanager_secret.ec2_ssh_public_key.arn,
            data.aws_secretsmanager_secret.nat_ssh_public_key.arn
        ]
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
    subnet_id     = var.private_subnet_ids[0]  # Using the first private subnet
    vpc_security_group_ids = [aws_security_group.moveo_ec2_security_group.id]
    iam_instance_profile = aws_iam_instance_profile.moveo_ec2_profile.name
    key_name      = var.ec2_key_name

    # Enable encryption for the root volume
    root_block_device {
        volume_type           = "gp3"
        volume_size           = 8
        encrypted             = true
        delete_on_termination = true
        tags = merge(var.tags, {
            Name        = "${var.environment}-ec2-root-volume"
            Environment = var.environment
            ManagedBy   = "Terraform"
        })
    }

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
        aws_security_group.moveo_alb_security_group
    ]
}
