# Add provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  # Backend configuration
  backend "s3" {
    bucket         = "mantix-assessment-statefile"
    key            = "mantix/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "mantix-assessment-lockfile"
  }
}


# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_files = ["~/.aws/credentials"]
}

module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  name                    = var.vpcname
  cidr                    = "10.0.0.0/16"
  azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

# Create a security group for the EC2 instance