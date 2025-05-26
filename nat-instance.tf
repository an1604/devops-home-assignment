# Security Group for NAT Instance
resource "aws_security_group" "moveo_nat_security_group" {
    name        = "${var.environment}-nat-security-group"
    description = "Security group for NAT instance"
    vpc_id      = aws_vpc.moveo_vpc.id

    # Allow inbound HTTP from private subnets
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
        description = "Allow HTTP from private subnets"
    }

    # Allow inbound HTTPS from private subnets
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
        description = "Allow HTTPS from private subnets"
    }

    # Allow inbound SSH from EIP for management
    dynamic "ingress" {
        for_each = var.enable_eip_for_ssh ? [1] : []
        content {
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            cidr_blocks = ["${aws_eip.ssh_access[0].public_ip}/32"]
            description = "Allow SSH from EIP for management"
        }
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
        Name        = "${var.environment}-nat-security-group"
        Environment = var.environment
    })
}

# IAM Role for NAT Instance
resource "aws_iam_role" "moveo_nat_role" {
    name = "${var.environment}-nat-role"

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
        Name        = "${var.environment}-nat-role"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })
}

# IAM Instance Profile for NAT
resource "aws_iam_instance_profile" "moveo_nat_profile" {
    name = "${var.environment}-nat-profile"
    role = aws_iam_role.moveo_nat_role.name
}

# IAM Policy Document for NAT Instance
data "aws_iam_policy_document" "moveo_nat_policy_doc" {
    statement {
        actions = [
            "ec2:*",
            "ec2:ModifyInstanceAttribute",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeRouteTables",
            "ec2:CreateRoute",
            "ec2:ReplaceRoute"
        ]
        effect    = "Allow"
        resources = ["*"]
    }
}

# IAM Policy for NAT Instance
resource "aws_iam_policy" "moveo_nat_policy" {
    name        = "${var.environment}-nat-policy"
    description = "Policy for NAT instance to manage routes and network settings"
    policy      = data.aws_iam_policy_document.moveo_nat_policy_doc.json

    tags = merge(var.tags, {
        Name        = "${var.environment}-nat-policy"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "moveo_nat_policy_attachment" {
    role       = aws_iam_role.moveo_nat_role.name
    policy_arn = aws_iam_policy.moveo_nat_policy.arn
}

# NAT Instance
resource "aws_instance" "moveo_nat" {
    ami           = "ami-0c7217cdde317cfec"  # Amazon Linux 2023 AMI in us-east-1
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.moveo_public_subnet[0].id  # Must be in public subnet
    vpc_security_group_ids = [aws_security_group.moveo_nat_security_group.id]
    iam_instance_profile = aws_iam_instance_profile.moveo_nat_profile.name
    key_name      = aws_key_pair.nat-instance-key-pair.key_name
    source_dest_check = false

    # Enable encryption for the root volume
    root_block_device {
        volume_type           = "gp3"
        volume_size           = 8
        encrypted             = true
        delete_on_termination = true
        tags = merge(var.tags, {
            Name        = "${var.environment}-nat-root-volume"
            Environment = var.environment
            ManagedBy   = "Terraform"
        })
    }

    # User data script to configure NAT
    user_data = <<-EOF
        #!/bin/bash
        # Enable IP forwarding
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        sysctl -p

        # Install iptables
        sudo apt update -y
        sudo apt install -y iptables-services
        sudo systemctl start iptables
        sudo systemctl enable iptables

        # Configure NAT
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        service iptables save
    EOF

    tags = merge(var.tags, {
        Name        = "${var.environment}-nat"
        Environment = var.environment
        ManagedBy   = "Terraform"
    })

    depends_on = [
        aws_security_group.moveo_nat_security_group,
        aws_key_pair.nat-instance-key-pair
    ]
}

# Route table entry for private subnets to use NAT instance
resource "aws_route" "private_nat_route" {
    count                  = length(var.availability_zones)
    route_table_id         = aws_route_table.moveo_private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id   = aws_instance.moveo_nat.primary_network_interface_id
}

# Add outputs for the NAT instance
output "nat_instance_id" {
    description = "The ID of the NAT instance"
    value       = aws_instance.moveo_nat.id
}

output "nat_instance_private_ip" {
    description = "The private IP address of the NAT instance"
    value       = aws_instance.moveo_nat.private_ip
}

# Note: Public IP output is now in eip.tf as nat_instance_eip
