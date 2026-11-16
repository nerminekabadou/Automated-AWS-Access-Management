"""GET /decision: entry point of the links in the admin email.

Verifies the signed link, then starts the cleanup Lambda asynchronously.
"""

import json
import os

import boto3

from decision_token import verify

lambda_client = boto3.client("lambda")


def _html(status_code, message):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "text/html; charset=utf-8"},
        "body": f"<!doctype html><title>IAM cleanup</title><p>{message}</p>",
    }


def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}
    username = params.get("username", "")
    action = params.get("action", "")

    if not verify(os.environ["DECISION_SECRET"], username, action,
                  params.get("expires"), params.get("token", "")):
        return _html(403, "This link is invalid or has expired.")

    lambda_client.invoke(
        FunctionName=os.environ["CLEANUP_FUNCTION_NAME"],
        InvocationType="Event",
        Payload=json.dumps({"username": username, "action": action}),
    )
    return _html(200, f"Request received: user <strong>{username}</strong> will be {action}d.")
