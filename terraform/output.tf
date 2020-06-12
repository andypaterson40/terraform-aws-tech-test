/*
Outputs
*/

# ELB dns name
output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

# Bastion public IP
output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}