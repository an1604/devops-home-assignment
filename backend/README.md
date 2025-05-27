# Terraform Backend Infrastructure

This directory contains the Terraform configuration for setting up the backend infrastructure required for state management. The setup is designed to work within AWS Free Tier limits.

## Infrastructure Components

### 1. S3 Bucket for State Storage
- **Purpose**: Stores Terraform state files securely
- **Free Tier Limits**:
  - 5GB storage
  - 20,000 GET requests per month
  - 2,000 PUT requests per month
- **Features**:
  - Versioning enabled for state file history
  - Server-side encryption (AES256)
  - Lifecycle rule to prevent accidental deletion

### 2. DynamoDB Table for State Locking
- **Purpose**: Prevents concurrent modifications to the state file
- **Free Tier Limits**:
  - 25 WCUs (Write Capacity Units)
  - 25 RCUs (Read Capacity Units)
  - 25GB of storage
- **Configuration**:
  - Uses PAY_PER_REQUEST billing mode (free tier eligible)
  - Primary key: LockID (String)

## Usage

1. **Initial Setup**:
   ```bash
   cd backend
   terraform init
   terraform apply
   ```

2. **State Management**:
   - State files are stored in S3: `moveo-terraform-state-2024`
   - State locking is handled by DynamoDB: `terraform-state-lock`
   - All state operations are encrypted

3. **Cost Considerations**:
   - S3: Free tier includes 5GB storage and 20,000 GET requests
   - DynamoDB: PAY_PER_REQUEST mode means you only pay for what you use
   - Both services are free tier eligible for 12 months

## Security

- State files are encrypted at rest using AES256
- S3 bucket has versioning enabled for state file history
- DynamoDB table uses PAY_PER_REQUEST for cost-effective locking
- Bucket has prevent_destroy lifecycle rule to prevent accidental deletion

## Important Notes

1. **Free Tier Monitoring**:
   - Monitor your AWS Billing Dashboard to ensure you stay within free tier limits
   - Set up billing alerts to avoid unexpected charges
   - Free tier resets monthly

2. **State File Size**:
   - Keep your state files small to stay within free tier limits
   - Regularly clean up old state versions if needed

3. **Access Control**:
   - The backend infrastructure is managed separately from the main infrastructure
   - IAM roles and policies should be properly configured for CI/CD access

## Maintenance

- Regularly check AWS Free Tier usage
- Monitor state file size and DynamoDB usage
- Review and clean up old state versions if needed
- Keep Terraform and provider versions updated

## References

- [AWS Free Tier Details](https://aws.amazon.com/free/)
- [Terraform S3 Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [AWS S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [AWS DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
