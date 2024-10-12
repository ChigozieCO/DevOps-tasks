variable "region" {
  description = "The region where the VPC will be located"
  type        = string
  default     = "us-east-1"
}

variable "vpcname" {
  description = "Vpc name"
  type        = string
}

variable "existing_key_name" {
  description = "Name of the existing key pair in AWS"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "server_name" {
  description = "Name of the server"
  type   = string
}