/*
Security group for nginx servers.
*/

# Security group, with inbound rules for ELB and bastion.
resource "aws_security_group" "web_instance_security_group" {
  vpc_id      = aws_vpc.nginx_vpc.id
  name        = "nginx-web-security-group"
  description = "Nginx web security group"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_elb_sg.id]
    description     = "Nginx ELB security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion.public_ip}/32"]
    description = "Bastion security group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx web security group"
  }
}