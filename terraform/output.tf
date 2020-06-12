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

# CloudWatch log group arn
output "cloudwatch_loggroup_arn" {
  value = "${aws_cloudwatch_log_group.log_group.arn}"
}

# Dynamodb table arn
output "dynamodb_table_name" {
  value = "${aws_dynamodb_table.dynamodb_table.arn}"
}

# Dynamodb table name
output "dynamodb_table_arn" {
  value = "${aws_dynamodb_table.dynamodb_table.name}"
}