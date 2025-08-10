import json
import boto3
import os
from datetime import datetime

# AWS Région par défaut
os.environ['AWS_DEFAULT_REGION'] = 'eu-west-2'


dynamodb = boto3.resource('dynamodb')
iam = boto3.client('iam')
secretsmanager = boto3.client('secretsmanager')
ses = boto3.client('ses')

# Noms des tables DynamoDB
ACCESS_REQUEST_TABLE = 'access-request-table'
IAM_USERS_TABLE = 'iam-users-table'

# Email expéditeur SES (doit être vérifié dans AWS SES)
FROM_EMAIL = 'jawhertalbi12@gmail.com'

def handler(event, context):
    print("Event received:", json.dumps(event))

    # Gestion des différents formats d'entrée
    if isinstance(event, str):
        event = json.loads(event)
    elif isinstance(event.get("body"), str):
        event = json.loads(event["body"])

    request_id = event.get("request_id")
    username = event.get("username")
    email = event.get("email")

    if not all([request_id, username, email]):
        return {
            "statusCode": 400,
            "body": json.dumps("Missing required fields: request_id, username, email")
        }

    try:
        # --- Création de l'utilisateur IAM ---
        try:
            iam.create_user(UserName=username)
            print(f"IAM user {username} created.")
        except iam.exceptions.EntityAlreadyExistsException:
            print(f"IAM user {username} already exists.")

        # --- Ajout du tag internship:true ---
        try:
            iam.tag_user(
                UserName=username,
                Tags=[
                    {"Key": "internship", "Value": " true"}
                ]
            )
            print(f"Tag internship:true added to {username}.")
        except Exception as e:
            print(f"Failed to tag user {username}: {str(e)}")

        # --- Création des clés IAM ---
        access_key_data = iam.create_access_key(UserName=username)
        access_key_id = access_key_data['AccessKey']['AccessKeyId']
        secret_access_key = access_key_data['AccessKey']['SecretAccessKey']
        print("Access keys created.")

        # --- Attachement de la politique ---
        policy_arn = 'arn:aws:iam::aws:policy/ReadOnlyAccess'
        iam.attach_user_policy(UserName=username, PolicyArn=policy_arn)
        print(f"Policy {policy_arn} attached to {username}.")

        # --- Stockage dans Secrets Manager ---
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
            print(f"Secret {secret_name} created.")
        except secretsmanager.exceptions.ResourceExistsException:
            secretsmanager.put_secret_value(
                SecretId=secret_name,
                SecretString=credentials_secret
            )
            print(f"Secret {secret_name} updated.")

        # --- Sauvegarde dans la table IAM_USERS_TABLE ---
        iam_users_table = dynamodb.Table(IAM_USERS_TABLE)
        iam_users_table.put_item(Item={
            'username': username,
            'email': email,
            'access_key_id': access_key_id,
            'secret_name': secret_name
        })
        print(f"User {username} saved in {IAM_USERS_TABLE}.")

        # --- Mise à jour du statut dans ACCESS_REQUEST_TABLE ---
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
        print(f"Request {request_id} updated in {ACCESS_REQUEST_TABLE}.")

        # --- Envoi de l'email SES ---
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
            print(f"Email sent to {email}.")
        except Exception as e:
            print(f"Failed to send email: {str(e)}")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": f"Provisioning complete for {username}",
                "secret_name": secret_name
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
