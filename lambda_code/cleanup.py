"""Disable or delete an expired IAM user, then record the result in DynamoDB."""

import json
import os

import boto3

dynamodb = boto3.resource("dynamodb")
iam = boto3.client("iam")


def _ignore_missing(call, **kwargs):
    try:
        call(**kwargs)
    except iam.exceptions.NoSuchEntityException:
        pass


def disable_user(username):
    """Deactivate access keys and remove console access; the user is kept."""
    for key in iam.list_access_keys(UserName=username)["AccessKeyMetadata"]:
        iam.update_access_key(UserName=username, AccessKeyId=key["AccessKeyId"], Status="Inactive")
    _ignore_missing(iam.delete_login_profile, UserName=username)


def delete_user(username):
    """IAM refuses to delete a user that still has attached resources, so remove them first."""
    for key in iam.list_access_keys(UserName=username)["AccessKeyMetadata"]:
        iam.delete_access_key(UserName=username, AccessKeyId=key["AccessKeyId"])
    _ignore_missing(iam.delete_login_profile, UserName=username)
    for device in iam.list_mfa_devices(UserName=username)["MFADevices"]:
        iam.deactivate_mfa_device(UserName=username, SerialNumber=device["SerialNumber"])
    for policy in iam.list_attached_user_policies(UserName=username)["AttachedPolicies"]:
        iam.detach_user_policy(UserName=username, PolicyArn=policy["PolicyArn"])
    for name in iam.list_user_policies(UserName=username)["PolicyNames"]:
        iam.delete_user_policy(UserName=username, PolicyName=name)
    for group in iam.list_groups_for_user(UserName=username)["Groups"]:
        iam.remove_user_from_group(UserName=username, GroupName=group["GroupName"])
    iam.delete_user(UserName=username)


ACTIONS = {"disable": disable_user, "delete": delete_user}


def lambda_handler(event, context):
    event = json.loads(event) if isinstance(event, str) else event
    username = event["username"]
    action = event["action"]
    if action not in ACTIONS:
        raise ValueError(f"Unknown action: {action}")

    ACTIONS[action](username)

    dynamodb.Table(os.environ["USERS_TABLE"]).update_item(
        Key={"username": username},
        UpdateExpression="SET #s = :status",
        ExpressionAttributeNames={"#s": "status"},
        ExpressionAttributeValues={":status": f"{action}d"},
    )
    return {"statusCode": 200, "body": json.dumps({"message": f"User {username} {action}d"})}
