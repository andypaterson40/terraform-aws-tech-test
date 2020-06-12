/*
Data
*/

# Get all AZ's within region
data "aws_availability_zones" "available" {}

# Get AWS identity
data "aws_caller_identity" "current" {}
