﻿# DevOps Home Assignment – Bonus Section

This repository implements the **Bonus Step** of the Moveo DevOps Home Assignment, focusing on robust, automated infrastructure deployment and secure remote state management. The project is now structured for best practices in team collaboration and CI/CD.

---

## Project Structure (Bonus Section)

```
.
├── backend/                # Terraform config for remote state (S3 + DynamoDB)
│   ├── main.tf
│   └── README.md
├── modules/                # Reusable Terraform modules
│   ├── vpc/
│   └── ec2-alb/
├── .github/workflows/      # CI/CD workflows
│   └── deploy.yml
├── main.tf                 # Main infrastructure entrypoint
├── outputs.tf              # Outputs for main stack
├── provider.tf             # AWS provider config
├── variables.tf            # Variable declarations
├── keypair.tf              # SSH keypair resources
├── ...
└── README.md               # (this file)
```

---

## Bonus Section Enhancements

### 1. Remote State Management (backend/)
- **Directory:** `backend/`
- **Purpose:** Provisions an S3 bucket (for state) and DynamoDB table (for locking) to enable safe, concurrent, and versioned state management.
- **How to Use:**
  1. `cd backend`
  2. `terraform init && terraform apply`
- **Details:** See [`backend/README.md`](backend/README.md) for full configuration, security, and cost details.

### 2. Automated Deployment Workflow
- **File:** `.github/workflows/deploy.yml`
- **Purpose:** GitHub Actions workflow for CI/CD. On push to `main` or `new-bonus-section`, it:
  - Validates Terraform config
  - Applies infrastructure changes
  - Outputs ALB DNS for access
- **Note:** Assumes backend state is already provisioned (see above).

### 3. Main Infrastructure as Code
- **Entrypoint:** `main.tf` (uses modules)
- **Modules:**
  - `modules/vpc/` – VPC, subnets, routing
  - `modules/ec2-alb/` – EC2, ALB, NAT, security
- **Backend Config:**
  - `main.tf` configures the backend to use the S3 bucket and DynamoDB table created in `backend/`.

---

## Quick Start (Bonus Section)

### 1. Provision Remote State Backend
```bash
cd backend
terraform init
terraform apply
```
- This creates the S3 bucket and DynamoDB table for state management.
- See [`backend/README.md`](backend/README.md) for details.

### 2. Deploy Main Infrastructure
```bash
cd ..   # Return to project root
terraform init   # Now uses remote backend
terraform plan
terraform apply
```

### 3. Outputs
After deployment, Terraform will output:
- **ALB DNS Name**: Application Load Balancer DNS
- **EC2 Public/Private IPs**
- **SSH/NAT EIPs and IDs**

See the [Outputs Reference](#outputs-reference) below for details.

### 4. SSH Access
```bash
ssh -i C:/ssh_keys/moveo_key_new ec2-user@<ec2_public_ip>
ssh -i C:/ssh_keys/moveo_key_new_nat ec2-user@<nat_instance_eip>
```

### 5. Cleanup
```bash
terraform destroy
```

---

## Outputs Reference
| Output Name              | Description                                 |
|-------------------------|---------------------------------------------|
| alb_dns_name            | The DNS name of the Application Load Balancer|
| ec2_public_ip           | The public IP address of the EC2 instance   |
| ec2_private_ip          | The private IP address of the EC2 instance  |
| ssh_access_eip          | The Elastic IP for SSH access               |
| nat_instance_eip        | The Elastic IP of the NAT instance          |
| nat_instance_id         | The ID of the NAT instance                  |
| nat_instance_private_ip | The private IP of the NAT instance          |

---

## Infrastructure Components (Modules)

### VPC & Networking (`modules/vpc/`)
- VPC with DNS support
- Public/private subnets (multi-AZ)
- Internet Gateway, route tables

### Application & Security (`modules/ec2-alb/`)
- Application Load Balancer (ALB)
- EC2 instance (private subnet)
- NAT instance (public subnet)
- Security groups, IAM roles, SSH keypairs
- User data for Docker/Nginx setup

---

## Security & Best Practices
- Remote state with locking (S3 + DynamoDB)
- Private subnets for application
- NAT for controlled outbound access
- Least-privilege security groups
- IAM roles for automation
- SSH key-based authentication

---

## Cost & Free Tier
- All resources (EC2, NAT, S3, DynamoDB, ALB) are configured to stay within AWS Free Tier limits where possible.
- Monitor your AWS Billing Dashboard to avoid unexpected charges.

---

## Troubleshooting & Maintenance
- See [`backend/README.md`](backend/README.md) for backend-specific notes.
- For main infra: check outputs, security groups, and AWS console for resource status.
- Use `terraform state list` and `terraform state show <resource>` for debugging.

---

## References
- [backend/README.md](backend/README.md) – Remote state backend details
- [Terraform S3 Backend Docs](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [AWS Free Tier](https://aws.amazon.com/free/)
