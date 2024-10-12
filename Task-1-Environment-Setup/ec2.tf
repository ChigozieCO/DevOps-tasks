# Retrieve the ami of windows server
data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name      = "name"
    values    = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name      = "architecture"
    values    = ["x86_64"]
  }
}

# Reference the existing AWS Key Pair
data "aws_key_pair" "existing_key" {
  key_name = var.existing_key_name  # Name of the existing key pair
}

# Configure a windows server
resource "aws_instance" "windows_server" {
  ami                    = data.aws_ami.windows_2022.id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.existing_key.key_name
  subnet_id              = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.windows_sg.id]

  tags                   = {
    Name                 = var.server_name
  }
}