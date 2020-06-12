# Security Group for ELB
resource "aws_security_group" "nginx_elb_sg" {
  vpc_id      = aws_vpc.nginx_vpc.id
  name        = "nginx_elb_security_group"
  description = "Nginx ELB security group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx elb security group"
  }
}

# Create a new load balancer
resource "aws_elb" "elb" {
  name            = "nginx-elb"
  security_groups = ["${aws_security_group.nginx_elb_sg.id}"]
  subnets         = aws_subnet.nginx_subnet.*.id

  listener {
    lb_port           = 80
    lb_protocol       = "tcp"
    instance_port     = 80
    instance_protocol = "tcp"
  }

  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}