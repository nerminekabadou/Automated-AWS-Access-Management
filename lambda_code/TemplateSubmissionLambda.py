import json
import boto3
import os
from datetime import datetime
import uuid
import traceback

# Région AWS par défaut
os.environ['AWS_DEFAULT_REGION'] = 'eu-west-2'

# Connexion DynamoDB (pas de endpoint_url)
dynamodb = boto3.resource('dynamodb')
ACCESS_REQUEST_TABLE = 'access-request-table'


def handler(event, context):
    try:
        print("Received event:", json.dumps(event))

        username = event.get("username")
        email = event.get("email")
        policies = event.get("policies")
        duration = event.get("duration_days")

        if not username or not email or not policies:
            print("Missing required fields")
            return {
                "statusCode": 400,
                "body": json.dumps({"message": "Missing fields"})
            }

        request_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat()

        table = dynamodb.Table(ACCESS_REQUEST_TABLE)
        print(f"Putting item into DynamoDB table {ACCESS_REQUEST_TABLE}")

        table.put_item(Item={
            "request_id": request_id,
            "username": username,
            "email": email,
            "policies": policies,
            "duration_days": duration,
            "status": "PENDING_PROVISIONING",
            "created_at": created_at
        })

        print("Put item succeeded")
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Request submitted",
                "request_id": request_id,
                "username": username,
                "email": email
            })
        }
    except Exception:
        traceback.print_exc()
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Internal error"})
        }
