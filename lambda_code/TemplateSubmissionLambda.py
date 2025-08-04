import json
import boto3
import os
from datetime import datetime
import uuid

# Configuration AWS pour LocalStack
os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'

# Connexion à LocalStack
dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:4566')

ACCESS_REQUEST_TABLE = 'access-request-table'

def handler(event, context):
    username = event.get("username")
    email = event.get("email")
    policies = event.get("policies")
    duration = event.get("duration_days")

    if not username or not email or not policies:
        return {
            "statusCode": 400,
            "body": {"message": "Missing fields"}
        }

    request_id = str(uuid.uuid4())
    created_at = datetime.utcnow().isoformat()
    table = dynamodb.Table(ACCESS_REQUEST_TABLE)

    table.put_item(Item={
        "request_id": request_id,
        "username": username,
        "email": email,
        "policies": policies,
        "duration_days": duration,
        "status": "PENDING_PROVISIONING",
        "created_at": created_at
    })

    return {
        "statusCode": 200,
        "body": {
            "message": "Request submitted",
            "request_id": request_id,
            "username": username,
            "email": email
        }
    }
