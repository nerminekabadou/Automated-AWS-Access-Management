import boto3
import os
from datetime import datetime
import urllib.parse

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')

def lambda_handler(event, context):
    table = dynamodb.Table(os.environ['USERS_TABLE'])
    today = datetime.utcnow().date().isoformat()

    expired_users = table.scan(
        FilterExpression="end_date <= :today AND #s NOT IN (:disabled, :deleted)",
        ExpressionAttributeValues={
            ":today": today,
            ":disabled": "disabled",
            ":deleted": "deleted"
        },
        ExpressionAttributeNames={"#s": "status"}
    ).get('Items', [])

    for user in expired_users:
        username = user['username']
        encoded_username = urllib.parse.quote(username)
        
        ses.send_email(
            Source=os.environ['FROM_EMAIL'],
            Destination={"ToAddresses": [os.environ['ADMIN_EMAIL']]},
            Message={
                "Subject": {"Data": f"Action Required: {username}"},
                "Body": {
                    "Text": {
                        "Data": f"User {username} expired\n\n"
                                f"Disable: {os.environ['ADMIN_DECISION_URL']}?username={encoded_username}&action=disable\n"
                                f"Delete: {os.environ['ADMIN_DECISION_URL']}?username={encoded_username}&action=delete"
                    }
                }
            }
        )

        table.update_item(
            Key={"username": username},
            UpdateExpression="SET #s = :status",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":status": "pending_action"}
        )

    return {
        "statusCode": 200,
        "body": f"Processed {len(expired_users)} users"
    }