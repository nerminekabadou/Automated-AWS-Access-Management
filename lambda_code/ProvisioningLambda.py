import json
import boto3
import os
from datetime import datetime, timedelta

dynamodb = boto3.resource('dynamodb')
iam = boto3.client('iam')

ACCESS_REQUEST_TABLE = os.environ['ACCESS_REQUEST_TABLE']
IAM_USERS_TABLE = os.environ['IAM_USERS_TABLE']

def handler(event, context):
    request_id = event.get("request_id")
    if not request_id:
        return {"status": "FAILED", "reason": "Missing request_id"}

    access_table = dynamodb.Table(ACCESS_REQUEST_TABLE)
    user_table = dynamodb.Table(IAM_USERS_TABLE)

    # Get request
    response = access_table.get_item(Key={"request_id": request_id})
    item = response.get("Item")
    if not item:
        return {"status": "FAILED", "reason": "Request not found"}

    username = item["username"]
    email = item["email"]
    policies = item["policies"]
    duration = item.get("duration_days", 7)

    # Create IAM User
    try:
        iam.create_user(UserName=username)
    except iam.exceptions.EntityAlreadyExistsException:
        pass

    for policy in policies:
        iam.attach_user_policy(UserName=username, PolicyArn=policy)

    keys = iam.create_access_key(UserName=username)['AccessKey']

    expiration = (datetime.utcnow() + timedelta(days=int(duration))).isoformat()
    user_table.put_item(Item={
        "user_id": str(uuid.uuid4()),
        "username": username,
        "email": email,
        "project": "ProvisionedByAdmin",
        "expiration_date": expiration,
        "status": "ACTIVE",
        "created_at": datetime.utcnow().isoformat(),
        "Delete_ressources": False
    })

    access_table.update_item(
        Key={"request_id": request_id},
        UpdateExpression="SET #s = :val",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":val": "PROVISIONED"}
    )

    return {
        "status": "SUCCESS",
        "access_key_id": keys["AccessKeyId"],
        "secret_access_key": keys["SecretAccessKey"]
    }
