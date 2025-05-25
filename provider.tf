provider "aws" {
  # use this shared_credentials_files if you want to use the credentials file
  # shared_credentials_files = ["%UserProfile%\\.aws\\credentials"]
  region = var.aws_region
  profile = var.aws_profile
}