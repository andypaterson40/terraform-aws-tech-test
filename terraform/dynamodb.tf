/*
Dynamodb table to hold 1 day of ec2 instance state information.
*/
resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "EC2-StateTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 4
  write_capacity = 4
  hash_key       = "InstanceId"
  range_key      = "ExpirationDateTTL"

  attribute {
    name = "InstanceId"
    type = "S"
  }

  attribute {
    name = "ExpirationDateTTL"
    type = "N"
  }

  ttl {
    attribute_name = "ExpirationDateTTL"
    enabled        = true
  }
}