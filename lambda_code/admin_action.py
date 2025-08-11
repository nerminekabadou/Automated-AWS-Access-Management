import boto3
import os
import json

lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    params = event.get('queryStringParameters', {})
    username = params.get('username')
    action = params.get('action')

    if not username or not action:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing username or action"})
        }

    lambda_client.invoke(
        FunctionName=os.environ['CLEANUP_FUNCTION_NAME'],
        InvocationType='Event',
        Payload=json.dumps({
            'username': username,
            'action': action
        })
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": f"Cleanup started for {username}"})
    }