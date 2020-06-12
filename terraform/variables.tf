/*
Variables for terraform configuration
*/

# Region
variable "region" {
  default = "eu-west-1"
}

# VPC CIDR range
variable "vpc-cidr" {
}

# Image ID/ AMI
variable "image-id" {
  default = "ami-cdbfa4ab"
}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

# Auto scaling minimum size
variable "minimum" {
  default = 2
}

# Bastion - Access from CIDR
variable "bastion_cidr" {
  default = "51.9.179.6/32"
}
