/*
Configuration to create auto scaling group so we can
utilise better control capacity.  
*/

# User data to be added to the launch configuration
locals {
  ec2-userdata = <<USERDATA
#!/bin/sh
yum install -y nginx
service nginx start
 
USERDATA
}

resource "aws_key_pair" "web" {
  key_name   = "nginx-key"
  public_key = file(pathexpand(var.public_key))
}

# Launch configuration - contains details for ec2 to launch
resource "aws_launch_configuration" "launch-configuration" {
  image_id                    = var.image-id
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.web.key_name
  name                        = "nginx-lc"
  security_groups             = ["${aws_security_group.web_instance_security_group.id}"]
  user_data                   = local.ec2-userdata
  associate_public_ip_address = true

}

# Auto scaling group
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = var.capacity
  launch_configuration = aws_launch_configuration.launch-configuration.id
  max_size             = length(data.aws_availability_zones.available.names)
  min_size             = var.minimum
  name                 = "nginx-asg"
  load_balancers       = ["${aws_elb.elb.name}"]
  vpc_zone_identifier  = aws_subnet.nginx_subnet.*.id

  tag {
    key                 = "Name"
    value               = "ngnix-server"
    propagate_at_launch = true
  }

}