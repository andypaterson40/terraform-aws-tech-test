/*
Create Lambda, IAM Role to execute lambda. IAM Policy to add logs to CloudWatch, 
get EC2 status and permission to items to DynamoDB.
Also added CloudWatch Rule to trigger Lambda.
*/

# Zip python file ready for Lambda.
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/monitor_state.py"
  output_path = "${path.module}/../lambdas/monitor_state.zip"
}

# Create IAM role for executing Lambda
resource "aws_iam_role" "iam_for_lambda_execution" {
  name = "lambda_execution_ec2_state_monitor"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create Lambda
resource "aws_lambda_function" "lambda_ec2_state" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "monitor_state"
  role             = aws_iam_role.iam_for_lambda_execution.arn
  handler          = "monitor_state.handler"
  source_code_hash = data.archive_file.lambda.output_path

  runtime = "python3.8"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.dynamodb_table.name
    }
  }
}

# Add CloudWatch logs for executing Lambda.
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_ec2_state.function_name}"
  retention_in_days = 7
}

# IAM poilcy for Lambda to create logs, add items to DynamoDB and collect EC2 status details.
resource "aws_iam_policy" "lambda_policy" {
  name        = "ec2_state_lambda_policy"
  path        = "/"
  description = "IAM policy for logging from lambda ${aws_lambda_function.lambda_ec2_state.function_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.log_group.arn}",
      "Effect": "Allow"
    },
    {
      "Action": [
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInstances"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "dynamodb:PutItem"
      ],
      "Resource": "${aws_dynamodb_table.dynamodb_table.arn}",
      "Effect": "Allow"
    }

  ]
}
EOF
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "lambda_attachment" {
  role       = aws_iam_role.iam_for_lambda_execution.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Create CloudWatch rule to trigger Lambda.
resource "aws_cloudwatch_event_rule" "one_hour_trigger" {
  name                = "one-hour-trigger"
  description         = "Triggers every hour"
  schedule_expression = "rate(1 hour)"
}

# Create CloudWatch event target (Lambda).
resource "aws_cloudwatch_event_target" "lambda_every_hour" {
  rule      = aws_cloudwatch_event_rule.one_hour_trigger.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda_ec2_state.arn
}

# Add permission for CloudWatch to call Lambda.
resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ec2_state.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.one_hour_trigger.arn
}