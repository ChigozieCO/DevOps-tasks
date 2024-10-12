# Task

Set up a Windows Server environment and install the required software, including Docker and Git. Document your setup process.

# Implementation

This task can be performed on your local computer on a cloud platform like AWS, Azure, Google cloud, digital ocean etc, however I decided to use the AWS cloud platform as AWS is widely used in the industry and using it instead of VMWare or Virtualbox demonstrates real-world skills.

Since automation is the foundation of DevOps, I made the decision to automate this configuration using Terraform for Infrastructure as Code. Writing reusable code excites me particularly since it improves consistency, scalability, and process efficiency. Teams can work more productively when infrastructure can be automated, and I get great satisfaction from developing solutions that increase productivity while preserving flexibility for unforeseen circumstances.

## Terraform Script

The Windows server will be setup in an EC2 instance in AWS, the EC2 instance will be located in a virtual private cloud (VPC) network on AWS and I decided against using the default VPC opting to create my own project specific VPC using the AWS VPC module.

The decision to leverage on an existing module is owing to the fact that the module is tested, maintained, and reliable and so there isn't any need to reinvent the wheel for such a low level task such as VPC creation.

I also used an S3 bucket and DynamoDb table to save my state file and lock file respectively. I made the decision to manually create my bucket and table via the management console in order to circumvent the two step creation process that would have been required were I to use the same Terraform script to create them where I will use them.

### Provider Configuration

To begin, I wrote the configuration for the provider and added my backend configuration. The code for that is seen below:

```hcl
# Add provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
```

### Create VPC 

As I already mentioned, I made use of the [AWS VPC Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) in the creation of my VPC. 

Calling the module, I added all the necessary parameters.

### Create Security group

After the VPC configuration, I wrote the configuration for my EC2 security group. My security group allowed RDP and HTTP traffic into the server.

### Create Windows Server

Finally I created the windows server using the `aws_instance` resource. 

I used the data block to retrieve the ami of the windows 2022 server and also to retrieve an existing key pair from my AWS account.

I decided to use an existing key pair and not create the key pair directly in terraform using the `tls_private_key` resource for security purposes. The latter will cause the private key to become a part of the terraform state and create a potential of it being exposed. Whereas the formal ensures that my private key is not a part of the Terraform state file.

## Connect to the server

When the server was up and running to test my setup I connected to the server using Remote Desktop Connection.

I retrieve the public IP from the output of my terraform run and decrypted the password using the private key of my key pair, along with the username I was able to connect to the server.


The image below, shows a success connection.

![remote-desktop-connection-to-server](./rdp-connection.png)

## Install Required Software

For a more granular control over the installation and configuration of the required software I opted to use Ansible for my server configuration instead of the `user_data` argument of terraform.

While Terraform is excellent for provisioning infrastructure, Ansible excels in managing the configuration and software installation on that infrastructure.

I made use of the Dynamic inventory feature of Ansible which allows you to automatically gather and manage hosts from various sources, such as cloud providers, databases, or other custom scripts.

I filtered with instance-state-name and platform, to ensure I only included hosts that were windows based and were running.

Here is what my dynamic inventory script looked like:

