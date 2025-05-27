# Security Group for ALB
resource "aws_security_group" "moveo_alb_security_group" {
    name        = "${var.environment}-alb-security-group"
    description = "Security group for Application Load Balancer"
    vpc_id      = aws_vpc.moveo_vpc.id

    # Allow inbound HTTPS from anywhere (needed for public web access)
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  
        description = "Allow HTTPS from anywhere (public web access)"
    }

    # Allow inbound HTTP from anywhere (needed for public web access)
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP from anywhere"
    }

    # Allow all outbound traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all outbound traffic"
    }

    tags = merge(var.tags, {
        Name = "${var.environment}-alb-security-group"
        Environment = var.environment
    })
}

# Application Load Balancer (ALB)
resource "aws_lb" "moveo_alb" {
    name               = "${var.environment}-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.moveo_alb_security_group.id]
    subnets            = aws_subnet.moveo_public_subnet[*].id

    tags = merge(var.tags, {
        Name        = "${var.environment}-alb"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })
}

# ALB Target Group
resource "aws_lb_target_group" "moveo_target_group" {
    name     = "${var.environment}-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.moveo_vpc.id

    health_check {
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
    }

    tags = merge(var.tags, {
        Name        = "${var.environment}-tg"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "moveo_tg_attachment" {
    target_group_arn = aws_lb_target_group.moveo_target_group.arn
    target_id        = aws_instance.moveo_ec2.id
    port             = 80
}

# ALB Listener
resource "aws_lb_listener" "moveo_listener" {
    load_balancer_arn = aws_lb.moveo_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.moveo_target_group.arn
    }
}

# Output the ALB DNS name
output "alb_dns_name" {
    description = "The DNS name of the load balancer"
    value       = aws_lb.moveo_alb.dns_name
} 