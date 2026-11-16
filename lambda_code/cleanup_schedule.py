"""Daily scheduler: email the admin about IAM users whose access has expired."""

import json
import os
from datetime import datetime, timezone

import boto3

from decision_token import build_link

dynamodb = boto3.resource("dynamodb")
ses = boto3.client("ses")


def find_expired_users(table, today):
    """Scan all pages of the users table for expired, still-active users."""
    kwargs = {
        "FilterExpression": "end_date <= :today AND NOT #s IN (:disabled, :deleted, :pending)",
        "ExpressionAttributeValues": {
            ":today": today,
            ":disabled": "disabled",
            ":deleted": "deleted",
            ":pending": "pending_action",
        },
        "ExpressionAttributeNames": {"#s": "status"},
    }
    while True:
        page = table.scan(**kwargs)
        yield from page.get("Items", [])
        if "LastEvaluatedKey" not in page:
            return
        kwargs["ExclusiveStartKey"] = page["LastEvaluatedKey"]


def lambda_handler(event, context):
    table = dynamodb.Table(os.environ["USERS_TABLE"])
    today = datetime.now(timezone.utc).date().isoformat()
    base_url = os.environ["ADMIN_DECISION_URL"]
    secret = os.environ["DECISION_SECRET"]
    ttl_hours = int(os.environ.get("LINK_TTL_HOURS", "24"))

    processed = 0
    for user in find_expired_users(table, today):
        username = user["username"]
        ses.send_templated_email(
            Source=os.environ["FROM_EMAIL"],
            Destination={"ToAddresses": [os.environ["ADMIN_EMAIL"]]},
            Template=os.environ["SES_TEMPLATE_NAME"],
            TemplateData=json.dumps({
                "username": username,
                "disable_url": build_link(base_url, secret, username, "disable", ttl_hours),
                "delete_url": build_link(base_url, secret, username, "delete", ttl_hours),
            }),
        )
        table.update_item(
            Key={"username": username},
            UpdateExpression="SET #s = :status",
            ExpressionAttributeNames={"#s": "status"},
            ExpressionAttributeValues={":status": "pending_action"},
        )
        processed += 1

    return {"statusCode": 200, "body": json.dumps({"processed": processed})}
