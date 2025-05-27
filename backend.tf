terraform {
  backend "s3" {
    bucket         = "moveo-terraform-state-2024"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

