import json
import boto3
import os
from datetime import datetime

LOCALSTACK_ENDPOINT = 'http://host.docker.internal:4566'

os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'

dynamodb = boto3.resource('dynamodb', endpoint_url=LOCALSTACK_ENDPOINT)
iam = boto3.client('iam', endpoint_url=LOCALSTACK_ENDPOINT)
secretsmanager = boto3.client('secretsmanager', endpoint_url=LOCALSTACK_ENDPOINT)
ses = boto3.client('ses', endpoint_url=LOCALSTACK_ENDPOINT)

os.environ['ACCESS_REQUEST_TABLE'] = 'access-request-table'
os.environ['IAM_USERS_TABLE'] = 'iam-users-table'

ACCESS_REQUEST_TABLE = os.environ['ACCESS_REQUEST_TABLE']
IAM_USERS_TABLE = os.environ['IAM_USERS_TABLE']

FROM_EMAIL = 'jawhertalbi12@gmail.com'

def handler(event, context):
    print("Event received:", event)

    if isinstance(event, str):
        event = json.loads(event)
    elif isinstance(event.get("body"), str):
        event = json.loads(event["body"])

    request_id = event.get("request_id")
    username = event.get("username")
    email = event.get("email")

    # DEBUG: Override email
    email = 'jawher.talbi@esprit.tn'

    if not all([request_id, username, email]):
        return {
            "statusCode": 400,
            "body": json.dumps("Missing required fields: request_id, username, email")
        }

    # Création utilisateur IAM, clés, secrets, mise à jour tables, envoi mail SES...

    try:
        iam.create_user(UserName=username)
    except iam.exceptions.EntityAlreadyExistsException:
        pass

    access_key_data = iam.create_access_key(UserName=username)
    access_key_id = access_key_data['AccessKey']['AccessKeyId']
    secret_access_key = access_key_data['AccessKey']['SecretAccessKey']

    policy_arn = 'arn:aws:iam::aws:policy/ReadOnlyAccess'
    iam.attach_user_policy(UserName=username, PolicyArn=policy_arn)

    secret_name = f"{username}-credentials"
    credentials_secret = json.dumps({
        "AccessKeyId": access_key_id,
        "SecretAccessKey": secret_access_key
    })

    try:
        secretsmanager.create_secret(
            Name=secret_name,
            Description=f"IAM credentials for {username}",
            SecretString=credentials_secret
        )
    except secretsmanager.exceptions.ResourceExistsException:
        secretsmanager.put_secret_value(
            SecretId=secret_name,
            SecretString=credentials_secret
        )

    iam_users_table = dynamodb.Table(IAM_USERS_TABLE)
    iam_users_table.put_item(Item={
        'username': username,
        'email': email,
        'access_key_id': access_key_id,
        'secret_name': secret_name
    })

    access_request_table = dynamodb.Table(ACCESS_REQUEST_TABLE)
    access_request_table.update_item(
        Key={'request_id': request_id},
        UpdateExpression="SET #s = :status, processed_at = :now",
        ExpressionAttributeNames={'#s': 'status'},
        ExpressionAttributeValues={
            ':status': 'APPROVED',
            ':now': datetime.utcnow().isoformat()
        }
    )

    try:
        ses.send_email(
            Source=FROM_EMAIL,
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'Access Approved'},
                'Body': {
                    'Text': {'Data': f"Your access request has been approved. Use secret name: {secret_name}"}
                }
            }
        )
    except Exception as e:
        print(f"Failed to send email: {str(e)}")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": f"Provisioning complete for {username}",
            "secret_name": secret_name
        })
    }
