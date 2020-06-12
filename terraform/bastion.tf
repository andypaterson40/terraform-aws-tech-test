/*
Create Bastion server which is accessable via SSH and connect
to the Nginx servers.
*/

# Create Bastion server
resource "aws_instance" "bastion" {
  ami                         = var.image-id
  key_name                    = aws_key_pair.web.key_name
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = element(aws_subnet.nginx_subnet.*.id, 0)
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }
}

# Create Security Group
resource "aws_security_group" "bastion_sg" {
  vpc_id      = aws_vpc.nginx_vpc.id
  name        = "bastion-security-group"
  description = "Bastion security group"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.bastion_cidr]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion security group"
  }
}