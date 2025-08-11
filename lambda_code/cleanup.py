import boto3
import os
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
iam = boto3.client('iam')
ses = boto3.client('ses')

def lambda_handler(event, context):
    event = json.loads(event) if isinstance(event, str) else event
    username = event['username']
    action = event['action']

    # Execute action
    if action == "disable":
        for key in iam.list_access_keys(UserName=username)['AccessKeyMetadata']:
            iam.update_access_key(
                UserName=username,
                AccessKeyId=key['AccessKeyId'],
                Status='Inactive'
            )
        try:
            iam.delete_login_profile(UserName=username)
        except:
            pass
    elif action == "delete":
        iam.delete_user(UserName=username)

    # Update DynamoDB
    for table in [os.environ['USERS_TABLE'], os.environ['REQUESTS_TABLE']]:
        dynamodb.Table(table).update_item(
            Key={"username": username},
            UpdateExpression="SET #s = :status",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":status": f"{action}d"}
        )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": f"User {username} {action}d"})
    }