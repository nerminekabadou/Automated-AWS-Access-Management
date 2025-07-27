import json
import boto3
import os
from datetime import datetime
import uuid

dynamodb = boto3.resource('dynamodb')
stepfunctions = boto3.client('stepfunctions')

ACCESS_REQUEST_TABLE = os.environ['ACCESS_REQUEST_TABLE']
STATE_MACHINE_ARN = os.environ['STATE_MACHINE_ARN']

def handler(event, context):
    body = json.loads(event.get("body", "{}"))
    username = body.get("username")
    email = body.get("email")
    policies = body.get("policies")
    duration = body.get("duration_days")

    if not username or not email or not policies:
        return {"statusCode": 400, "body": json.dumps({"message": "Missing fields"})}

    request_id = str(uuid.uuid4())
    created_at = datetime.utcnow().isoformat()
    table = dynamodb.Table(ACCESS_REQUEST_TABLE)

    table.put_item(Item={
        "request_id": request_id,
        "username": username,
        "email": email,
        "policies": policies,
        "duration_days": duration,
        "status": "PENDING_APPROVAL",
        "created_at": created_at
    })

    stepfunctions.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=json.dumps({"request_id": request_id})
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Request submitted", "request_id": request_id})
    }
