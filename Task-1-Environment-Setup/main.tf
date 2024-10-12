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

# Create VPC using terraform aws vpc module
module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  name                    = var.vpcname
  cidr                    = "10.0.0.0/16"
  azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames    = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
}

# Create a security group for the EC2 instance to allow http and rds traffic
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for the EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow incoming HTTP connections"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description  = "Allow incoming RDP connections"
    from_port    = 3389
    to_port      = 3389
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Windows-sg"
  }
}