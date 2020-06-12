'''
Function to get the EC2 instance status and add that data to dynamodb table.
'''
import json
import boto3
import os
import calendar

from datetime import datetime, timedelta

# Environment variable
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE')

def handler(event, context):
    # Get the dynamodb resource and table
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(DYNAMODB_TABLE)

    # Get the EC2 client and get all instance status details
    client = boto3.client("ec2")
    status = client.describe_instance_status(IncludeAllInstances = True)

    print("Starting function!")
    print("Total EC2 instances to monitor: " + str(len(status["InstanceStatuses"])))

    # Iterate through the list of instances found and add to dynamodb table.
    for i in status["InstanceStatuses"]:
        print("EC2 instance to monitor, InstanceId: ", i["InstanceId"])
        print("DetailedStatus :", i)
        print("InstanceState :", i["InstanceState"])
        print("InstanceStatus", i["InstanceStatus"])
        
        # Calculate the expiration/TTL time for the item
        now_utc = datetime.utcnow()
        ttl_date_utc = (datetime.utcnow() + timedelta(days=1))

        response = table.put_item(
           Item={
                'InstanceId': i["InstanceId"],
                'MonitorStateDate': now_utc.isoformat(),
                'ExpirationDateTTL': calendar.timegm(ttl_date_utc.utctimetuple()),
                'DetailedStatus': i,
                'InstanceState': i["InstanceState"],
                'InstanceStatus': i["InstanceStatus"]
            }
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Completed status check!')
    }