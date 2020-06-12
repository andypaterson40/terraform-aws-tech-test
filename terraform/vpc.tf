/*
Create VPC, Internet Gateway, Route Table and public Subnets
*/

# Create VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true

  tags = {
    Name = "nginx-vpc"
  }
}

# Create subnets, one for each AZ.
resource "aws_subnet" "nginx_subnet" {
  count = length(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.nginx_vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = cidrsubnet(var.vpc-cidr, 3, count.index)

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create route table
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.nginx_vpc.id
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "nginx-IG"
  }
}

# Create routes
resource "aws_route" "public_subnet_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_subnet_route_table.id
}

# Add subnets to route table
resource "aws_route_table_association" "public_subnet_route_table_association" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id = aws_subnet.nginx_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet_route_table.id
}